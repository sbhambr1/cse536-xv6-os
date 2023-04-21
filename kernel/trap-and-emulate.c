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

void handle_sret(struct vm_virtual_state *vms){
    printf("handle_sret\n");
    // TODO: Implement this function
}

void handle_mret(struct vm_virtual_state *vms){
    printf("handle_mret\n");
    uint32 mstatus = r_mstatus(); // read mstatus register
    uint32 mpp = (mstatus & MSTATUS_MPP_MASK) >> 0x11; // get the previous privilege level (mpp)

    // set the previous privilege level (mpp) to supervisor mode (mpp_s)
    mstatus &= ~MSTATUS_MPP_MASK; // clear mpp bits
    mstatus |= MSTATUS_MPP_S << 0x11 ; // set mpp bits to supervisor mode
    w_mstatus(mstatus); // write mstatus register

    // set the program count to the value of mepc
    uint32 mepc = r_mepc(); // read mepc register
    w_mtvec(mepc & ~0x3); // write mtvec register

    // clear the MED bit in mstatus
    mstatus &= ~MSTATUS_MIE; // clear MED bit
    w_mstatus(mstatus); // write mstatus register

    // execute the instruction
    asm volatile("mret");
}

void handle_ecall(struct vm_virtual_state *vms){
    printf("handle_ecall\n");
    // TODO: Implement this function
    // load syscall code from scause register
    uint32 code = r_scause() & 0x7FFFFFFF;
}

void handle_csrr(struct vm_virtual_state *vms, unsigned int rs1, unsigned int rd, unsigned int upper){
    printf("handle_csrr\n");
    // read the register at the upper bits
    // write the value to the rd register
}

void handle_csrw(struct vm_virtual_state *vms, unsigned int rs1, unsigned int rd, unsigned int upper){
    printf("handle_csrw\n");
    // read the value of the rs1 register
    // write the value to the upper bits
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

    struct vm_virtual_state *vms = (struct vm_virtual_state *)kalloc();
    memset(vms, 0, sizeof(struct vm_virtual_state));

    switch (upper){
        case 0x000:
            handle_ecall(vms);
            break;
        case 0x102:
            handle_sret(vms);
            break;
        case 0x302:
            handle_mret(vms);
            break;
        case 0x307:
            if(rs1 != 0 && rd == 0){
                handle_csrr(vms, rs1, rd, upper);
            } else if(rs1 == 0 && rd != 0){
                handle_csrw(vms, rs1, rd, upper);
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