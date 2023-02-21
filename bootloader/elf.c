#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "buf.h"
#include "elf.h"

#include <stdbool.h>

struct elfhdr* kernel_elfhdr;
struct proghdr* kernel_phdr;

uint64 find_kernel_load_addr(void) {
    // CSE 536: task 2.5.1
    kernel_elfhdr =  (struct elfhdr*)RAMDISK;
    kernel_phdr = (struct proghdr*)(RAMDISK + kernel_elfhdr->phoff + kernel_elfhdr->phentsize);
    uint64 kernel_load_addr = kernel_phdr->vaddr; 
    return kernel_load_addr;
}

uint64 find_kernel_size(void) {
    // CSE 536: task 2.5.2
    kernel_elfhdr = (struct elfhdr*)RAMDISK;
    uint64 kernel_size = kernel_elfhdr->shoff + (kernel_elfhdr->shnum * kernel_elfhdr->shentsize);
    return kernel_size;
}

uint64 find_kernel_entry_addr(void) {
    // CSE 536: task 2.5.3
    uint64 kernel_entry_addr = kernel_elfhdr->entry;
    return kernel_entry_addr;
}