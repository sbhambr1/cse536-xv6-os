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
    int priv; // 0 = U, 1 = S, 2 = M
};

void handle_sret(void){
    printf("handle_sret\n");
    // TODO: Implement this function
}

void handle_mret(void){
    printf("handle_mret\n");
    // TODO: Implement this function
}

void handle_ecall(void){
    printf("handle_ecall\n");
    // TODO: Implement this function
}

void handle_csrr(unsigned int rs1, unsigned int rd, unsigned int upper){
    printf("handle_csrr\n");
    // TODO: Implement this function
}

void handle_csrw(unsigned int rs1, unsigned int rd, unsigned int upper){
    printf("handle_csrw\n");
    // TODO: Implement this function
}

void trap_and_emulate(void) {
    /* Comes here when a VM tries to execute a supervisor instruction. */

    uint32 op       = 0;
    uint32 rd       = 0;
    uint32 rs1      = 0;
    uint32 upper    = 0;

    // Read the 32-bit instruction from the VM
    // opcode is in bits 6-0 and save in op
    // rd is in bits 11-7
    // rs1 is in bits 19-15
    // upper is in bits 31-20

    // Checking for ecall:        31..20-0x000, 19..15=0, 14..12=0, 11..7=0, 6..2=0x1C, 1..0=3
    // Checking for sret:         31..20=0x102, 19..15=0, 14..12=0, 11..7=0, 6..2=0x1C, 1..0=3
    // Checking for mret:         31..20=0x302, 19..15=0, 14..12=0, 11..7=0, 6..2=0x1C, 1..0=3
    // Checking for csrr & csrw:                          14..12=1,          6..2=0x1C, 1..0=3

    // read sepc register and mask to get only last 4 bytes
    uint32 instr = r_sepc() & 0xFFFFFFFF;
    // using kalloc, memset etc to allocate memory for the instruction

    // extract the opcode, rd, rs1, and upper bits
    op = instr & 0x7F;
    rd = (instr >> 7) & 0x1F;
    rs1 = (instr >> 15) & 0x1F;
    upper = (instr >> 20) & 0xFFF;

    printf("[PI] op = %x, rd = %x, rs1 = %x, upper = %x\n", op, rd, rs1, upper);

    // check if the instruction is sret
    if (upper == 0x102 && rd == 0 && rs1 == 0 && op == 0x1C) {
        // When a trap is taken into supervisor mode, SPIE is set to SIE, and SIE is set to 0. 
        // set 5th bit in sstatus register to 1st bit in sstatus register
        r_sstatus(r_sstatus() | (1 << 5));
        // set 1st bit in sstatus register to 0
        r_sstatus(r_sstatus() & ~(1 << 1));

        // execute sret instruction
    
        // When an SRET instruction is executed, SIE is set to SPIE, then SPIE is set to 1.
        // set 1st bit in sstatus register to 5th bit in sstatus register
        r_sstatus(r_sstatus() | (1 << 1));
        // set 5th bit in sstatus register to 1
        r_sstatus(r_sstatus() | (1 << 5));
    }

    // check if the instruction is mret
    if(upper == 0x302 && rd == 0 && rs1 == 0 && op == 0x1C) {
        // set SPVP, i.e., the 8th bit in ms to 0
        
    }

    switch (upper){
        case 0x000:
            handle_ecall();
            break;
        case 0x102:
            handle_sret();
            break;
        case 0x302:
            handle_mret();
            break;
        case 0x307:
            if(rs1 != 0 && rd == 0){
                handle_csrr(rs1, rd, upper);
            } else if(rs1 == 0 && rd != 0){
                handle_csrw(rs1, rd, upper);
            }
            break;
        default:
            printf("Invalid instruction\n");
            break;
    }

}

void trap_and_emulate_init(void) {
    /* Create and initialize all state for the VM */
    struct vm_virtual_state *vms = (struct vm_virtual_state *)kalloc();

    // User trap setup
    vms->ustatus = (struct vm_reg){.code = 0x000, .mode = 0, .val = 0};
    vms->uie = (struct vm_reg){.code = 0x004, .mode = 0, .val = 0};
    vms->utvec = (struct vm_reg){.code = 0x005, .mode = 0, .val = 0};

    // User trap handling
    vms->uscratch = (struct vm_reg){.code = 0x040, .mode = 0, .val = 0};
    vms->uepc = (struct vm_reg){.code = 0x041, .mode = 0, .val = 0};
    vms->ucause = (struct vm_reg){.code = 0x042, .mode = 0, .val = 0};
    vms->utval = (struct vm_reg){.code = 0x043, .mode = 0, .val = 0};
    vms->uip = (struct vm_reg){.code = 0x044, .mode = 0, .val = 0};

    // Supervisor trap setup
    vms->sstatus = (struct vm_reg){.code = 0x100, .mode = 1, .val = 0};
    vms->sedeleg = (struct vm_reg){.code = 0x102, .mode = 1, .val = 0};
    vms->sideleg = (struct vm_reg){.code = 0x103, .mode = 1, .val = 0};
    vms->sie = (struct vm_reg){.code = 0x104, .mode = 1, .val = 0};
    vms->stvec = (struct vm_reg){.code = 0x105, .mode = 1, .val = 0};
    vms->scounteren = (struct vm_reg){.code = 0x106, .mode = 1, .val = 0};

    // Supervisor page table register
    vms->satp = (struct vm_reg){.code = 0x180, .mode = 1, .val = 0};

    // Machine information registers
    vms->mvendorid = (struct vm_reg){.code = 0xF11, .mode = 2, .val = 637365353336};
    vms->marchid = (struct vm_reg){.code = 0xF12, .mode = 2, .val = 0};
    vms->mimpid = (struct vm_reg){.code = 0xF13, .mode = 2, .val = 0};
    vms->mhartid = (struct vm_reg){.code = 0xF14, .mode = 2, .val = 0};

    // Machine trap setup registers
    vms->mstatus = (struct vm_reg){.code = 0x300, .mode = 2, .val = 0};
    vms->misa = (struct vm_reg){.code = 0x301, .mode = 2, .val = 0};
    vms->medeleg = (struct vm_reg){.code = 0x302, .mode = 2, .val = 0};
    vms->mideleg = (struct vm_reg){.code = 0x303, .mode = 2, .val = 0};
    vms->mie = (struct vm_reg){.code = 0x304, .mode = 2, .val = 0};
    vms->mtvec = (struct vm_reg){.code = 0x305, .mode = 2, .val = 0};
    vms->mcounteren = (struct vm_reg){.code = 0x306, .mode = 2, .val = 0};
    vms->mstatush = (struct vm_reg){.code = 0x310, .mode = 2, .val = 0};

    // Machine trap handling registers
    vms->mscratch = (struct vm_reg){.code = 0x340, .mode = 2, .val = 0};
    vms->mepc = (struct vm_reg){.code = 0x341, .mode = 2, .val = 0};
    vms->mcause = (struct vm_reg){.code = 0x342, .mode = 2, .val = 0};
    vms->mtval = (struct vm_reg){.code = 0x343, .mode = 2, .val = 0};
    vms->mip = (struct vm_reg){.code = 0x344, .mode = 2, .val = 0};
    vms->mtinst = (struct vm_reg){.code = 0x34A, .mode = 2, .val = 0};
    vms->mtval2 = (struct vm_reg){.code = 0x34B, .mode = 2, .val = 0};

    // Current execution privilege level
    vms->priv = 2; // 0 = U, 1 = S, 2 = M

    // boot the VM in the M mode by setting 11th and 12th bit of mstatus to 1
    vms->mstatus.val = vms->mstatus.val | (1 << 11) | (1 << 12);
    
}