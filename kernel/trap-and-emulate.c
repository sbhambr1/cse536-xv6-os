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
    struct vm_reg ustatus = {.code = 0x000, .mode = 0, .val = 0};
    struct vm_reg uie = {.code = 0x004, .mode = 0, .val = 0};
    struct vm_reg utvec = {.code = 0x005, .mode = 0, .val = 0};

    // User trap handling
    struct vm_reg uscratch = {.code = 0x040, .mode = 0, .val = 0};
    struct vm_reg uepc = {.code = 0x041, .mode = 0, .val = 0};
    struct vm_reg ucause = {.code = 0x042, .mode = 0, .val = 0};
    struct vm_reg utval = {.code = 0x043, .mode = 0, .val = 0};
    struct vm_reg uip = {.code = 0x044, .mode = 0, .val = 0};

    // Supervisor trap setup
    struct vm_reg sstatus = {.code = 0x100, .mode = 1, .val = 0};
    struct vm_reg sedeleg = {.code = 0x102, .mode = 1, .val = 0};
    struct vm_reg sideleg = {.code = 0x103, .mode = 1, .val = 0};
    struct vm_reg sie = {.code = 0x104, .mode = 1, .val = 0};
    struct vm_reg stvec = {.code = 0x105, .mode = 1, .val = 0};
    struct vm_reg scounteren = {.code = 0x106, .mode = 1, .val = 0};

    // Supervisor page table register
    struct vm_reg satp = {.code = 0x180, .mode = 1, .val = 0};

    // Machine information registers
    struct vm_reg mvendorid = {.code = 0xF11, .mode = 2, .val = 637365353336};
    struct vm_reg marchid = {.code = 0xF12, .mode = 2, .val = 0};
    struct vm_reg mimpid = {.code = 0xF13, .mode = 2, .val = 0};
    struct vm_reg mhartid = {.code = 0xF14, .mode = 2, .val = 0};

    // Machine trap setup registers
    struct vm_reg mstatus = {.code = 0x300, .mode = 2, .val = 0};
    struct vm_reg misa = {.code = 0x301, .mode = 2, .val = 0};
    struct vm_reg medeleg = {.code = 0x302, .mode = 2, .val = 0};
    struct vm_reg mideleg = {.code = 0x303, .mode = 2, .val = 0};
    struct vm_reg mie = {.code = 0x304, .mode = 2, .val = 0};
    struct vm_reg mtvec = {.code = 0x305, .mode = 2, .val = 0};
    struct vm_reg mcounteren = {.code = 0x306, .mode = 2, .val = 0};
    struct vm_reg mstatush = {.code = 0x310, .mode = 2, .val = 0};

    // Machine trap handling registers
    struct vm_reg mscratch = {.code = 0x340, .mode = 2, .val = 0};
    struct vm_reg mepc = {.code = 0x341, .mode = 2, .val = 0};
    struct vm_reg mcause = {.code = 0x342, .mode = 2, .val = 0};
    struct vm_reg mtval = {.code = 0x343, .mode = 2, .val = 0};
    struct vm_reg mip = {.code = 0x344, .mode = 2, .val = 0};
    struct vm_reg mtinst = {.code = 0x34A, .mode = 2, .val = 0};
    struct vm_reg mtval2 = {.code = 0x34B, .mode = 2, .val = 0};

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