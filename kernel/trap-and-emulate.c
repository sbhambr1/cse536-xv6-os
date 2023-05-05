#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "stdbool.h"
#include "stdlib.h"

struct vm_virtual_state vms;
uint64 TOR = 0;
bool PMP = false;

// Program to convert binary to hex
long int binaryToHex(long int n) {
    int remainder; 
    long int hex = 0, i = 1;
    while (n != 0) {
        remainder = n % 10;
        hex = hex + remainder * i;
        i = i * 2;
        n = n / 10;
    }
    return hex;
}

// Struct to keep VM registers (Sample; feel free to change.)
struct vm_reg {
    int     code;
    int     mode;
    uint64  val;
};

// Keep the virtual state of the VM's privileged registers
struct vm_virtual_state {

    // array of registers
    struct vm_reg regs[40];

    // User trap setup
    struct vm_reg ustatus;
    struct vm_reg uie;
    struct vm_reg utvec;

    // User trap handling
    struct vm_reg uscratch;
    struct vm_reg uepc;
    struct vm_reg ucause;
    struct vm_reg utval;
    struct vm_reg uip;

    // Supervisor trap setup
    struct vm_reg sstatus;
    struct vm_reg sedeleg;
    struct vm_reg sideleg;
    struct vm_reg sie;
    struct vm_reg stvec;
    struct vm_reg scounteren;

    // Supervisor page table register
    struct vm_reg satp;

    // Machine information registers
    struct vm_reg mvendorid;
    struct vm_reg marchid;
    struct vm_reg mimpid;
    struct vm_reg mhartid;

    // Machine trap setup registers
    struct vm_reg mstatus;
    struct vm_reg misa;
    struct vm_reg medeleg;
    struct vm_reg mideleg;
    struct vm_reg mie;
    struct vm_reg mtvec;
    struct vm_reg mcounteren;
    struct vm_reg mstatush;

    // Machine trap handling registers
    struct vm_reg mscratch;
    struct vm_reg mepc;
    struct vm_reg mcause;
    struct vm_reg mtval;
    struct vm_reg mip;
    struct vm_reg mtinst;
    struct vm_reg mtval2;

    // Process trapframe registers
    struct vm_reg sscratch;
    struct vm_reg sepc;
    struct vm_reg scause;
    struct vm_reg stval;
    struct vm_reg sip;

    struct vm_reg pmpaddr0;
    struct vm_reg pmpcfg0;

    // Current execution privilege level
    int priv; // 0 = U, 1 = S, 2 = M
};

int uvmcopy_pt(pagetable_t old, pagetable_t new){

    pte_t *pte = kalloc();
    uint64 pa, i;
    uint flags;
    struct proc *p = myproc();

    for(i = 0; i < p->sz; i += PGSIZE){
        pa = PTE2PA(*pte);
        flags = PTE_FLAGS(*pte);
        mappages(new, i, PGSIZE, pa, flags);
    }
    for(i = 80000000; i < 80400000; i += PGSIZE){
        pa = PTE2PA(*pte);
        flags = PTE_FLAGS(*pte);
        mappages(new, i, PGSIZE, pa, flags);
    }
    // another for loop
    return 0;
}

void uvmunmap_pt(pagetable_t pagetable, uint64 va, uint64 npages, int do_free){

    uint64 a;
    pte_t *pte = kalloc();

    for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
        if(do_free){
            uint64 pa = PTE2PA(*pte);
            kfree((void*)pa);
        }
        *pte = 0;
    }

}

void handle_sret(struct proc *p){

    if(vms.priv >= 1){
        unsigned long x = vms.regs[8].val;
        unsigned long int spp = (x >> 8) & 0x1; // get the previous privilege level (spp)
        x &= ~(1 << 0x8); // set SPP bit to 0
        unsigned long int spie = (x >> 5) & 0x1; // get the previous interrupt enable bit (spie)
        x |= spie << 1; // set SIE bit to SPIE
        x &= (1 << 0x5); // set SPIE bit to 1
        vms.priv = spp ? 1 : 0; // set the current privilege level (priv) to spp
        vms.regs[8].val = x; // write sstatus register
        p->trapframe->epc = vms.regs[35].val; // set the program count to the value of sepc
    }
    else{
        setkilled(p);
    }
}

void handle_mret(struct proc *p){

    if(vms.priv >= 2){
        unsigned long x = vms.regs[19].val;
        unsigned long int mpp = (x >> 11) & 0x1; // get the previous privilege level (mpp)
        x &= ~MSTATUS_MPP_MASK; // clear MPP bits
        unsigned long int mpie = (x >> 7) & 0x1; // get the previous interrupt enable bit (mpie)
        x |= mpie << 3; // set MIE bit to MPIE
        x &= (1 << 0x7); // set MPIE bit to 1
        x &= ~(1 << 0x17); // clear MPRV bit
        vms.priv = mpp ? 1 : 0; // set the current privilege level (priv) to mpp
        vms.regs[19].val = x; // write mstatus register
        p->trapframe->epc = vms.regs[28].val; // set the program count to the value of mepc
    }
    else{
        setkilled(p);
    }
    if(PMP){
        pagetable_t kernel_pt = proc_pagetable(p);
        uvmcopy_pt(p->pagetable, kernel_pt);
        vms.regs[14].val = (uint64)kernel_pt;
        uvmunmap_pt(kernel_pt, TOR, 1, 1);
    }
}

void trap_and_emulate_ecall(void){

    struct proc *p = myproc(); 
    vms.regs[35].val = p->trapframe->epc; // read program counter and write to sepc
    p->trapframe->epc = vms.regs[12].val; // jump to stvec
    vms.priv = 1; // raise privilege level to supervisor mode  
}

void handle_csrr(struct proc *p, unsigned int rs1, unsigned int rd, unsigned int upper){
    
    uint32 value = 0;
    
    // iterate through the vms csr array to find the csr
    for(int i = 0; i < 39; i++){
        if(vms.regs[i].code == upper){
            if(vms.priv >= vms.regs[i].mode){
                value = vms.regs[i].val;
                uint64* rd_p = &(p->trapframe->ra) + rd - 1;
                *rd_p = value;    
            }
            else{
                setkilled(p);
            }
        break;
        }
    }
    p->trapframe->epc += 4;
    
}

void handle_csrw(struct proc *p, unsigned int rs1, unsigned int rd, unsigned int upper){

    // iterate through the vms csr array to find the csr
    for(int i = 0; i < 39; i++){
        if(vms.regs[i].code == upper){
            if(i == 15 && vms.priv == 0){ // writing to mvendorid is only allowed in machine mode or supervisor mode
                setkilled(p);
            }
            else if(vms.priv >= vms.regs[i].mode){
                uint64* rs1_p= &(p->trapframe->ra) + rs1 - 1;
                if(i == 15 && *rs1_p == 0x0){ // writing 0x0 to mvendorid is not allowed
                    setkilled(p);
                }
                if(i == 39 || i == 40){ 
                    PMP = true;
                }
                vms.regs[i].val = *rs1_p;
            }
            else{
                setkilled(p);
            }
        break;
        }
    }
    p->trapframe->epc += 4;

}


void trap_and_emulate(void) {
    /* Comes here when a VM tries to execute a supervisor instruction. */

    /* Retrieve all required values from the instruction */
    uint64 addr     = 0;
    uint32 op       = 0; //6..0
    uint32 rd       = 0; //11..7
    uint32 funct3   = 0; //14..12
    uint32 rs1      = 0; //19..15
    uint32 upper    = 0; //31..20

    // Checking for ecall:        31..20-0x000, 19..15=0, 14..12=0, 11..7=0, 6..2=0x1C, 1..0=3
    // Checking for sret:         31..20=0x102, 19..15=0, 14..12=0, 11..7=0, 6..2=0x1C, 1..0=3
    // Checking for mret:         31..20=0x302, 19..15=0, 14..12=0, 11..7=0, 6..2=0x1C, 1..0=3
    // Checking for csrr & csrw:                          14..12=1,          6..2=0x1C, 1..0=3

    // Checking for ecall:  upper = 000000000000, rs1 = 00000, funct3 = 000, rd = 00000, op = 1110011
    // Checking for csrw:                                      funct3 = 001,             op = 1110011
    // Checking for csrr:                                      funct3 = 010,             op = 1110011
    // Checking for sret:   upper = 000100000010, rs1 = 00000, funct3 = 000, rd = 00000, op = 1110011
    // Checking for mret:   upper = 001100000010, rs1 = 00000, funct3 = 000, rd = 00000, op = 1110011

    struct proc *p = myproc();

    addr = r_sepc(); // read the address from the program counter
    uint32 addr_p = addr & 0xFFFFFFFF; // only use the lower 32 bits

    int *kp = kalloc();
    copyin(p->pagetable, (char *)kp, addr, 4);
    uint64 instr = *(uint64 *)kp;

    // extract the op, rd, funct3, rs1 and upper bits from the instruction
    op = (instr & 0x7F); // 6..0
    rd = (instr >> 7) & 0x1F; // 11..7
    funct3 = (instr >> 12) & 0x7; // 14..12
    rs1 = (instr >> 15) & 0x1F; // 19..15
    upper = (instr >> 20) & 0xFFF; // 31..20

    if(funct3 == 0x0 && upper == 0){
        printf("(PI at %p)\n", 
                addr_p);
    }
    else{
        printf("(PI at %p) op = %x, rd = %x, funct3 = %x, rs1 = %x, uimm = %x\n", 
                addr_p, op, rd, funct3, rs1, upper);
    }

    if(funct3 == 0x1){
        handle_csrw(p = p, rs1 = rs1, rd = rd, upper = upper);
    }
    else if(funct3 == 0x2){
        handle_csrr(p = p, rs1 = rs1, rd = rd, upper = upper);
    }
    else if(funct3 == 0x0){
        if(upper == 0){
            trap_and_emulate_ecall();
        } else if(upper == 0x102){
            handle_sret(p = p);
        } else if(upper == 0x302){
            handle_mret(p = p);
        }
    }
    else{
        printf("trap_and_emulate: invalid instruction\n");
        setkilled(p);
    }

    /* Clone the VM process' page tables
    Unmap memory regions that the PMP says should not be accessible in U/S-mode.
    The only PMP variant you must support is the TOR one you supported in assignment #1.
    If the VM tries to access PMP protected memory region, it should raise a page fault
    Then, you simply kill the VM. */

    // creates page table
    // when writing the address of the page table to satp, OS will trap to kernel
    // current page table is: guest PA -> host PA, so make a copy to a kernel page table and write that address to satp

    // if(funct3 == 0 && upper == 0x102 && vms.priv == 1){ // sret
    //     pagetable_t kernel_pt = proc_pagetable(p);
    //     uvmcopy_pt(p->pagetable, kernel_pt); //do in csrw
    //     uint64 invalid_memory = TOR;
    //     uvmunmap_pt(kernel_pt, invalid_memory, 1, 1); // in mret if pmp, unmap invalid memory
    //     vms.regs[14].val = (uint64)kernel_pt;
    // }
    
}

void trap_and_emulate_init(void) {
    /* Create and initialize all state for the VM */

    // User trap setup
    vms.regs[0]  = vms.ustatus = (struct vm_reg){.code = 0x000, .mode = 0, .val = 0};
    vms.regs[1]  = vms.uie = (struct vm_reg){.code = 0x004, .mode = 0, .val = 0};
    vms.regs[2]  = vms.utvec = (struct vm_reg){.code = 0x005, .mode = 0, .val = 0};

    // User trap handling
    vms.regs[3]  = vms.uscratch = (struct vm_reg){.code = 0x040, .mode = 0, .val = 0};
    vms.regs[4]  = vms.uepc = (struct vm_reg){.code = 0x041, .mode = 0, .val = 0};
    vms.regs[5]  = vms.ucause = (struct vm_reg){.code = 0x042, .mode = 0, .val = 0};
    vms.regs[6]  = vms.utval = (struct vm_reg){.code = 0x043, .mode = 0, .val = 0};
    vms.regs[7]  = vms.uip = (struct vm_reg){.code = 0x044, .mode = 0, .val = 0};

    // Supervisor trap setup
    vms.regs[8]  = vms.sstatus = (struct vm_reg){.code = 0x100, .mode = 1, .val = 0};
    vms.regs[9]  = vms.sedeleg = (struct vm_reg){.code = 0x102, .mode = 1, .val = 0};
    vms.regs[10] = vms.sideleg = (struct vm_reg){.code = 0x103, .mode = 1, .val = 0};
    vms.regs[11] = vms.sie = (struct vm_reg){.code = 0x104, .mode = 1, .val = 0};
    vms.regs[12] = vms.stvec = (struct vm_reg){.code = 0x105, .mode = 1, .val = 0};
    vms.regs[13] = vms.scounteren = (struct vm_reg){.code = 0x106, .mode = 1, .val = 0};

    // Supervisor page table register
    vms.regs[14] = vms.satp = (struct vm_reg){.code = 0x180, .mode = 1, .val = 0};

    // add supervisor trap handlin registers

    // Machine information registers
    vms.regs[15] = vms.mvendorid = (struct vm_reg){.code = 0xF11, .mode = 1, .val = 0xC5E536};
    vms.regs[16] = vms.marchid = (struct vm_reg){.code = 0xF12, .mode = 2, .val = 0};
    vms.regs[17] = vms.mimpid = (struct vm_reg){.code = 0xF13, .mode = 2, .val = 0};
    vms.regs[18] = vms.mhartid = (struct vm_reg){.code = 0xF14, .mode = 2, .val = 0};

    // Machine trap setup registers
    vms.regs[19] = vms.mstatus = (struct vm_reg){.code = 0x300, .mode = 2, .val = 0};
    vms.regs[20] = vms.misa = (struct vm_reg){.code = 0x301, .mode = 2, .val = 0};
    vms.regs[21] = vms.medeleg = (struct vm_reg){.code = 0x302, .mode = 2, .val = 0};
    vms.regs[22] = vms.mideleg = (struct vm_reg){.code = 0x303, .mode = 2, .val = 0};
    vms.regs[23] = vms.mie = (struct vm_reg){.code = 0x304, .mode = 2, .val = 0};
    vms.regs[24] = vms.mtvec = (struct vm_reg){.code = 0x305, .mode = 2, .val = 0};
    vms.regs[25] = vms.mcounteren = (struct vm_reg){.code = 0x306, .mode = 2, .val = 0};
    vms.regs[26] = vms.mstatush = (struct vm_reg){.code = 0x310, .mode = 2, .val = 0};

    // Machine trap handling registers
    vms.regs[27] = vms.mscratch = (struct vm_reg){.code = 0x340, .mode = 2, .val = 0};
    vms.regs[28] = vms.mepc = (struct vm_reg){.code = 0x341, .mode = 2, .val = 0};
    vms.regs[29] = vms.mcause = (struct vm_reg){.code = 0x342, .mode = 2, .val = 0};
    vms.regs[30] = vms.mtval = (struct vm_reg){.code = 0x343, .mode = 2, .val = 0};
    vms.regs[31] = vms.mip = (struct vm_reg){.code = 0x344, .mode = 2, .val = 0};
    vms.regs[32] = vms.mtinst = (struct vm_reg){.code = 0x34A, .mode = 2, .val = 0};
    vms.regs[33] = vms.mtval2 = (struct vm_reg){.code = 0x34B, .mode = 2, .val = 0};

    // Process trapframe registers
    vms.regs[34] = vms.sscratch = (struct vm_reg){.code = 0x140, .mode = 1, .val = 0};
    vms.regs[35] = vms.sepc = (struct vm_reg){.code = 0x141, .mode = 1, .val = 0};
    vms.regs[36] = vms.scause = (struct vm_reg){.code = 0x142, .mode = 1, .val = 0};
    vms.regs[37] = vms.stval = (struct vm_reg){.code = 0x143, .mode = 1, .val = 0};
    vms.regs[38] = vms.sip = (struct vm_reg){.code = 0x144, .mode = 1, .val = 0};

    vms.regs[39] = vms.pmpaddr0 = (struct vm_reg){.code = 0x3B0, .mode = 2, .val = 0};
    vms.regs[40] = vms.pmpcfg0 = (struct vm_reg){.code = 0x3A0, .mode = 2, .val = 0};

    // Current execution privilege level
    vms.priv = 2; // 0 = U, 1 = S, 2 = M

    // boot the VM in the M mode by setting 11th and 12th bit of mstatus to 1
    vms.mstatus.val = vms.mstatus.val | (1 << 11) | (1 << 12);
    
}