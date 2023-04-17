#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

// Struct to keep VM registers (Sample; feel free to change.)
struct vm_reg {
    int     code;
    int     mode;
    uint64  val;
};

// Keep the virtual state of the VM's privileged registers
struct vm_virtual_state {
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

    // Current execution privilege level
    int priv; // 0 = U, 1 = S, 3 = M
};

// Initialize the virtual state of the VM's privileged registers

void trap_and_emulate_init(void) {
    // User trap setup
    struct vm_reg ustatus = {0, 0, 0};
    struct vm_reg uie = {0, 0, 0};
    struct vm_reg utvec = {0, 0, 0};

    // User trap handling
    struct vm_reg uscratch = {0, 0, 0};
    struct vm_reg uepc = {0, 0, 0};
    struct vm_reg ucause = {0, 0, 0};
    struct vm_reg utval = {0, 0, 0};
    struct vm_reg uip = {0, 0, 0};

    // Supervisor trap setup
    struct vm_reg sstatus = {0, 0, 0};
    struct vm_reg sedeleg = {0, 0, 0};
    struct vm_reg sideleg = {0, 0, 0};
    struct vm_reg sie = {0, 0, 0};
    struct vm_reg stvec = {0, 0, 0};
    struct vm_reg scounteren = {0, 0, 0};

    // Supervisor page table register
    struct vm_reg satp = {0, 0, 0};

    // Machine information registers
    struct vm_reg mvendorid = {0, 0, 0};
    struct vm_reg marchid = {0, 0, 0};
    struct vm_reg mimpid = {0, 0, 0};
    struct vm_reg mhartid = {0, 0, 0};

    // Machine trap setup registers
    struct vm_reg mstatus = {0, 0, 0};
    struct vm_reg misa = {0, 0, 0};
    struct vm_reg medeleg = {0, 0, 0};
    struct vm_reg mideleg = {0, 0, 0};
    struct vm_reg mie = {0, 0, 0};
    struct vm_reg mtvec = {0, 0, 0};
    struct vm_reg mcounteren = {0, 0, 0};
    struct vm_reg mstatush = {0, 0, 0};

    // Machine trap handling registers
    struct vm_reg mscratch = {0, 0, 0};
    struct vm_reg mepc = {0, 0, 0};
    struct vm_reg mcause = {0, 0, 0};
    struct vm_reg mtval = {0, 0, 0};
    struct vm_reg mip = {0, 0, 0};
    struct vm_reg mtinst = {0, 0, 0};
    struct vm_reg mtval2 = {0, 0, 0};

    // Current execution privilege level
    int priv = 3; // 0 = U, 1 = S, 3 = M
}

void trap_and_emulate(void) {
    /* Comes here when a VM tries to execute a supervisor instruction. */

    uint32 op       = 0;
    uint32 rd       = 0;
    uint32 rs1      = 0;
    uint32 upper    = 0;

    printf("[PI] op = %x, rd = %x, rs1 = %x, upper = %x\n", op, rd, rs1, upper);
}

void trap_and_emulate_init(void) {
    /* Create and initialize all state for the VM */
}