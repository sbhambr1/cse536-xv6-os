/* This file contains code for a generic page fault handler for processes. */
#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "elf.h"

#include "sleeplock.h"
#include "fs.h"
#include "buf.h"

int loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz);
int flags2perm(int flags);

/* CSE 536: (2.4) read current time. */
uint64 read_current_timestamp() {
  uint64 curticks = 0;
  acquire(&tickslock);
  curticks = ticks;
  wakeup(&ticks);
  release(&tickslock);
  return curticks;
}

bool psa_tracker[PSASIZE];

/* All blocks are free during initialization. */
void init_psa_regions(void)
{
    for (int i = 0; i < PSASIZE; i++) 
        psa_tracker[i] = false;
}

/* Evict heap page to disk when resident pages exceed limit */
void evict_page_to_disk(struct proc* p) {
    /* Find free block */
    int blockno = 0;
    // Find 4 free blocks in the PSA.
    for (int i = 0; i < PSASIZE; i+=4) {
        if (psa_tracker[i] == false) {
            psa_tracker[i] = true;
            blockno = i;
            break;
        }
    }
    
    // Find the victim page address and victim timestamp using FIFO.
    uint64 victim_addr = 0, idx = 0;
    uint64 victim_timestamp = 0xFFFFFFFFFFFFFFFF;
    for(int i=0; i<MAXHEAP; i++) {
        if(p->heap_tracker[i].loaded == true) {
            if(p->heap_tracker[i].last_load_time < victim_timestamp) {
                victim_addr = p->heap_tracker[i].addr;
                victim_timestamp = p->heap_tracker[i].last_load_time;
                idx = i;
            }
        }
    }

    p->heap_tracker[idx].startblock = blockno;
    p->heap_tracker[idx].loaded = false;

    /* Print statement. */
    print_evict_page(p->heap_tracker[idx].addr, p->heap_tracker[idx].startblock);

    /* Read memory from the user to kernel memory first. */
    // Copy victim page from user memory to kernel memory using copyin function.
    char *kernel_alloc;
    kernel_alloc = (char*)kalloc();
    copyin(p->pagetable, kernel_alloc, (char*)p->heap_tracker[idx].addr, PGSIZE);
    
    /* Write to the disk blocks. Below is a template as to how this works. There is
     * definitely a better way but this works for now. :p */
    // write the kernel memory to the 4 disk blocks using memmove and bwrite
    for (int i = 0; i < 4; i++) {
        struct buf* b;
        b = bread(1, PSASTART+(blockno+i));
        memmove(b->data, kernel_alloc, 1024);
        bwrite(b);
        brelse(b);
        kernel_alloc += 1024;
    }


    /* Unmap swapped out page */
    // use the victim address to unmap the page using uvmunmap
    uvmunmap(p->pagetable, p->heap_tracker[idx].addr, 1, 1);

    /* Update the resident heap tracker. */
    p->resident_heap_pages -= 1;
}

/* Retrieve faulted page from disk. */
void retrieve_page_from_disk(struct proc* p, uint64 uvaddr) {
    /* Find where the page is located in disk */
    int blockno = 0;
    for(int i=0; i<MAXHEAP; i++) {
        if(p->heap_tracker[i].addr == uvaddr) {
            blockno = p->heap_tracker[i].startblock;
            break;
        }
    }

    p->heap_tracker[blockno].loaded = false;

    /* Copy from temp kernel page to uvaddr (use copyout) */
    char *kernel_alloc;
    kernel_alloc = (char*)kalloc();

    /* Read the disk block into temp kernel page. */
    for (int i = 0; i < 4; i++) {
        struct buf* b;
        b = bread(1, PSASTART+(blockno+i));
        memmove(kernel_alloc, b->data, 1024);
        brelse(b);
        kernel_alloc += 1024;
    }
    
    copyout(p->pagetable, (char*)uvaddr, kernel_alloc-PGSIZE, PGSIZE);

    /* Print statement. */
    print_retrieve_page(uvaddr, blockno);

    /* Create a kernel page to read memory temporarily into first. */
    
}


void page_fault_handler(void) 
{
    /* Current process struct */
    struct proc *p = myproc();

    /* Track whether the heap page should be brought back from disk or not. */
    bool load_from_disk = false;

    /* Find faulting address. */
    uint64 faulting_addr = 0;
    faulting_addr = r_stval();
    
    // get the faulting address from stval and find the base address of the page
    // faulting_addr = PGROUNDDOWN(faulting_addr);
    faulting_addr >>= 12;
    faulting_addr <<= 12;
    print_page_fault(p->name, faulting_addr);

    for(int i=0; i<MAXHEAP; i++) {
        if(p->heap_tracker[i].addr == faulting_addr) {
            if(p->heap_tracker[i].startblock != -1) {
                load_from_disk = true;
            }
            goto heap_handle;
        }
    }

    // iterate through each program section header using binary's elf header
    struct elfhdr elf;
    struct proghdr ph;
    struct inode *ip;
    int i, off;
    uint64 pagesize = PGSIZE, allowed_size = 0, offset = 0, sz = 0;
    pagetable_t pagetable = 0;
    char* path = p->name;

    // same checks as in exec.c
    begin_op();    

    if((ip = namei(path)) == 0){
        end_op();
    }
    ilock(ip);
    
    // read the elf header
    if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
        goto bad;

    if(elf.magic != ELF_MAGIC)
        goto bad;

    if((pagetable = p->pagetable) == 0)
        goto bad;

    // read the program section headers to find the one that contains the faulting address
    for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
        if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
            goto bad;
        if(ph.type != ELF_PROG_LOAD)
            continue;
        if(ph.memsz < ph.filesz)
            goto bad;
        if(ph.vaddr + ph.memsz < ph.vaddr)
            goto bad;
        if(ph.vaddr % PGSIZE != 0)
            goto bad;
        // find the program section header that contains the faulting address
        if((faulting_addr >= ph.vaddr) && (faulting_addr < (ph.vaddr + ph.memsz))){

            allowed_size = ph.vaddr + ph.memsz - faulting_addr;
            if (allowed_size < pagesize)
                pagesize = allowed_size;

            offset = faulting_addr - ph.vaddr + ph.off;

            // allocate a free page for the faulting address
            uvmalloc(pagetable, faulting_addr, faulting_addr + pagesize, flags2perm(ph.flags));
            // load the program section into the allocated page
            loadseg(pagetable, faulting_addr, ip, offset, pagesize);
            print_load_seg(faulting_addr, ph.off, pagesize);
            goto out;
        }
    }
    iunlockput(ip);

    /* Go to out, since the remainder of this code is for the heap. */
    goto out;

heap_handle:
    /* 2.4: Check if resident pages are more than heap pages. If yes, evict. */
    if (p->resident_heap_pages >= MAXRESHEAP) {
        evict_page_to_disk(p);
    }

    /* 2.3: Map a heap page into the process' address space. (Hint: check growproc) */
    uint64 size, idx;
    uvmalloc(p->pagetable, faulting_addr, faulting_addr+PGSIZE, PTE_W);

    /* 2.4: Update the last load time and the loaded boolean for the loaded heap page in p->heap_tracker. */
    for(int i=0; i<MAXHEAP; i++) {
        if(p->heap_tracker[i].addr == faulting_addr) {
            p->heap_tracker[i].last_load_time = read_current_timestamp();
            p->heap_tracker[i].loaded = true;
            break;
        }
    }
    
    /* 2.4: Heap page was swapped to disk previously. We must load it from disk. */
    if (load_from_disk) {
        retrieve_page_from_disk(p, faulting_addr);
    }

    /* Track that another heap page has been brought into memory. */
    p->resident_heap_pages++;

    // CHECK!
    if (p->sz > faulting_addr + PGSIZE)
        p->sz = p->sz;
    else{
        p->sz = faulting_addr + PGSIZE;
    }

    goto out;

bad:
    if(pagetable)
        proc_freepagetable(pagetable, sz);
    if(ip){
        iunlockput(ip);
        end_op();
    }

out:
    /* Flush stale page table entries. This is important to always do. */
    sfence_vma();
    return;
}