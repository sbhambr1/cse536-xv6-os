#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "stdbool.h"

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
    struct vm_reg regs[34];

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
    struct vm_reg s0;
    struct vm_reg s1;
    struct vm_reg a0;
    struct vm_reg a1;
    struct vm_reg a2;
    struct vm_reg a3;
    struct vm_reg a4;
    struct vm_reg a5;

    // Current execution privilege level
    int priv; // 0 = U, 1 = S, 2 = M
};

void handle_sret(struct vm_virtual_state *vms){
    printf("handle_sret\n");
    // uint32 mstatus = r_mstatus(); // read mstatus register
    // uint32 spp = (mstatus >> 8) & 0x1; // get the previous privilege level (spp)
    // uint32 sp = spp ? MSTATUS_MPP_S : MSTATUS_MPP_U; // get the previous privilege level (sp)

    // // set the previous privilege level (MPP) to user mode (MPP_U)
    // mstatus &= ~MSTATUS_MPP_MASK; // clear MPP bits
    // mstatus |= sp << 0x11 ; // set MPP bits to user mode
    // w_mstatus(mstatus); // write mstatus register

    // // set the program count to the value of sepc
    // uint32 sepc = r_sepc(); // read sepc register
    // w_mtvec(sepc & ~0x3); // write mtvec register

    // // clear the SED bit in mstatus
    // mstatus &= ~MSTATUS_MIE;
    // w_mstatus(mstatus); // write mstatus register

    // // execute the instruction
    // asm volatile("sret");
}

void handle_mret(struct vm_virtual_state *vms){
    printf("handle_mret\n");
    // uint32 mstatus = r_mstatus(); // read mstatus register
    // // uint32 mpp = (mstatus & MSTATUS_MPP_MASK) >> 0x11; // get the previous privilege level (mpp)

    // // set the previous privilege level (mpp) to supervisor mode (mpp_s)
    // mstatus &= ~MSTATUS_MPP_MASK; // clear mpp bits
    // mstatus |= MSTATUS_MPP_S << 0x11 ; // set mpp bits to supervisor mode
    // w_mstatus(mstatus); // write mstatus register

    // // set the program count to the value of mepc
    // uint32 mepc = r_mepc(); // read mepc register
    // w_mtvec(mepc & ~0x3); // write mtvec register

    // // clear the MED bit in mstatus
    // mstatus &= ~MSTATUS_MIE; // clear MED bit
    // w_mstatus(mstatus); // write mstatus register

    // // execute the instruction
    // asm volatile("mret");
}

void handle_ecall(struct vm_virtual_state *vms){
    printf("handle_ecall\n");
    // printf("mstatus\n", vms->mstatus.val);
    // // TODO: Implement this function
    // // load syscall code from scause register
    // uint32 code = r_scause() & 0xf;
    // uint32 p_mode = (r_scause() >> 32) & 0x3;
    // printf("code: %x\n", code);
    // printf("p_mode: %x\n", p_mode);

    // // check SEDELEG for the code
    // // uint32 sedeleg = r_sedeleg();
    // // printf("sedeleg: %x\n", sedeleg);
    // // check the 9th bit of sedeleg for supervisor ecall
    // if(code ==8 && p_mode == 1){
    //     // read program counter and write to sepc 
    //     uint32 pc = r_pc();
    //     w_sepc(pc);
    //     // raise privilege level to supervisor mode
    //     vms->priv = 1;
    //     vms->mstatus.val |= vms->mstatus.val | (1 << 11) | (0 << 12);
    //     // jump to stvec
    //     uint32 stvec = r_stvec();
    //     w_pc(stvec);
    //     // call kernel trap handler using ecall with 1
    //     asm volatile("ecall");
    //     // return to sepc
    //     uint32 sepc = r_sepc();
    //     w_pc(sepc);
    // }
    // // check the 0xb bit of sedeleg for hypervisor ecall
    // else if(code ==8 && p_mode == 3){
    //     // read program counter and write to mepc
    //     uint32 pc = r_pc();
    //     w_mepc(pc);
    //     // raise privilege level to machine mode
    //     vms->priv = 2;
    //     vms->mstatus.val |= vms->mstatus.val | (1 << 11) | (1 << 12);
    //     // jump to mtvec
    //     uint32 mtvec = r_mtvec();
    //     w_pc(mtvec);
    //     // call sbi trap handler using ecall with 0
    //     asm volatile("ecall");
    //     // return to mepc
    //     uint32 mepc = r_mepc();
    //     w_pc(mepc);
    // }
}

void handle_csrr(struct vm_virtual_state *vms, unsigned int rs1, unsigned int rd, unsigned int upper){
    
    /* The CSRRS (Atomic Read and Set Bits in CSR) instruction reads the value of the CSR, zero-extends the value to XLEN bits, 
    and writes it to integer register rd
    For both CSRRS and CSRRC, if rs1 = x0 , then the instruction will not write to the CSR at all, and so shall not cause any of the side effects that might 
    otherwise occur on a CSR write, such as raising illegal instruction exceptions on accesses to read-only CSRs
    Both CSRRS and CSRRC always read the addressed CSR and cause any read side effects regardless of rs1 and rd fields
    The CSRRS and CSRRC instructions have same behavior so are shown as CSRR
    The assembler pseudoinstruction to read a CSR, CSRR rd, csr , is encoded as CSRRS rd, csr, x0 */

    uint32 value = 0;
    struct proc *p = myproc();
    
    // iterate through the vms csr array to find the csr
    for(int i = 0; i < 35; i++){
        if(vms->regs[i].code == upper){
            value = vms->regs[i].val;
            break;
        }
    }

    p->trapframe->a1 = value;
    p->trapframe->epc += 4;
    
}

void handle_csrw(struct vm_virtual_state *vms, unsigned int rs1, unsigned int rd, unsigned int upper){
    
    /* The CSRRW (Atomic Read/Write CSR) instruction atomically swaps values in the CSRs and integer registers
    CSRRW reads the old value of the CSR, zero-extends the value to XLEN bits, then writes it to integer register rd
    A CSRRW with rs1 = x0 will attempt to write zero to the destination CSR.
    The assembler pseudoinstruction to write a CSR, CSRW csr, rs1 , is encoded as CSRRW x0, csr, rs1 , 
    while CSRWI csr, uimm , is encoded as CSRRWI x0, csr, uimm . */

    uint32 value = 0;
    struct proc *p = myproc();

    // iterate through the vms csr array to find the csr
    for(int i = 0; i < 35; i++){
        if(vms->regs[i].code == upper){
            value = vms->regs[i].val;
            break;
        }
    }

    for(int i = 0; i < 35; i++){
        if(vms->regs[i].code == rd){
            vms->regs[i].val = value;
            break;
        }  
    }

    p->trapframe->epc += 4;

}

void trap_and_emulate(void) {
    /* Comes here when a VM tries to execute a supervisor instruction. */
    struct vm_virtual_state *vms = (struct vm_virtual_state *)kalloc();
    memset(vms, 0, sizeof(struct vm_virtual_state));

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

    printf("(PI at %p) op = %x, rd = %x, funct3 = %x, rs1 = %x, uimm = %x\n", 
                addr_p, op, rd, funct3, rs1, upper);

    if(funct3 == 0x1){
        handle_csrw(vms, rs1 = rs1, rd = rd, upper = upper);
    }
    else if(funct3 == 0x2){
        handle_csrr(vms, rs1 = rs1, rd = rd, upper = upper);
    }
    else if(funct3 == 0x0){
        setkilled(p);
        if(upper == 0){
            handle_ecall(vms);
        } else if(upper == 0x102){
            handle_sret(vms);
        } else if(upper == 0x302){
            handle_mret(vms);
        }
    }
    else{
        printf("trap_and_emulate: invalid instruction\n");
        setkilled(p);
    }
}

void trap_and_emulate_init(void) {
    /* Create and initialize all state for the VM */
    struct vm_virtual_state *vms = (struct vm_virtual_state *)kalloc();

    // User trap setup
    vms->regs[0]  = vms->ustatus = (struct vm_reg){.code = 0x000, .mode = 0, .val = 0};
    vms->regs[1]  = vms->uie = (struct vm_reg){.code = 0x004, .mode = 0, .val = 0};
    vms->regs[2]  = vms->utvec = (struct vm_reg){.code = 0x005, .mode = 0, .val = 0};

    // User trap handling
    vms->regs[3]  = vms->uscratch = (struct vm_reg){.code = 0x040, .mode = 0, .val = 0};
    vms->regs[4]  = vms->uepc = (struct vm_reg){.code = 0x041, .mode = 0, .val = 0};
    vms->regs[5]  = vms->ucause = (struct vm_reg){.code = 0x042, .mode = 0, .val = 0};
    vms->regs[6]  = vms->utval = (struct vm_reg){.code = 0x043, .mode = 0, .val = 0};
    vms->regs[7]  = vms->uip = (struct vm_reg){.code = 0x044, .mode = 0, .val = 0};

    // Supervisor trap setup
    vms->regs[8]  = vms->sstatus = (struct vm_reg){.code = 0x100, .mode = 1, .val = 0};
    vms->regs[9]  = vms->sedeleg = (struct vm_reg){.code = 0x102, .mode = 1, .val = 0};
    vms->regs[10] = vms->sideleg = (struct vm_reg){.code = 0x103, .mode = 1, .val = 0};
    vms->regs[11] = vms->sie = (struct vm_reg){.code = 0x104, .mode = 1, .val = 0};
    vms->regs[12] = vms->stvec = (struct vm_reg){.code = 0x105, .mode = 1, .val = 0};
    vms->regs[13] = vms->scounteren = (struct vm_reg){.code = 0x106, .mode = 1, .val = 0};

    // Supervisor page table register
    vms->regs[14] = vms->satp = (struct vm_reg){.code = 0x180, .mode = 1, .val = 0};

    // Machine information registers
    vms->regs[15] = vms->mvendorid = (struct vm_reg){.code = 0xF11, .mode = 2, .val = 637365353336};
    vms->regs[16] = vms->marchid = (struct vm_reg){.code = 0xF12, .mode = 2, .val = 0};
    vms->regs[17] = vms->mimpid = (struct vm_reg){.code = 0xF13, .mode = 2, .val = 0};
    vms->regs[18] = vms->mhartid = (struct vm_reg){.code = 0xF14, .mode = 2, .val = 0};

    // Machine trap setup registers
    vms->regs[19] = vms->mstatus = (struct vm_reg){.code = 0x300, .mode = 2, .val = 0};
    vms->regs[20] = vms->misa = (struct vm_reg){.code = 0x301, .mode = 2, .val = 0};
    vms->regs[21] = vms->medeleg = (struct vm_reg){.code = 0x302, .mode = 2, .val = 0};
    vms->regs[22] = vms->mideleg = (struct vm_reg){.code = 0x303, .mode = 2, .val = 0};
    vms->regs[23] = vms->mie = (struct vm_reg){.code = 0x304, .mode = 2, .val = 0};
    vms->regs[24] = vms->mtvec = (struct vm_reg){.code = 0x305, .mode = 2, .val = 0};
    vms->regs[25] = vms->mcounteren = (struct vm_reg){.code = 0x306, .mode = 2, .val = 0};
    vms->regs[26] = vms->mstatush = (struct vm_reg){.code = 0x310, .mode = 2, .val = 0};

    // Machine trap handling registers
    vms->regs[27] = vms->mscratch = (struct vm_reg){.code = 0x340, .mode = 2, .val = 0};
    vms->regs[28] = vms->mepc = (struct vm_reg){.code = 0x341, .mode = 2, .val = 0};
    vms->regs[29] = vms->mcause = (struct vm_reg){.code = 0x342, .mode = 2, .val = 0};
    vms->regs[30] = vms->mtval = (struct vm_reg){.code = 0x343, .mode = 2, .val = 0};
    vms->regs[31] = vms->mip = (struct vm_reg){.code = 0x344, .mode = 2, .val = 0};
    vms->regs[32] = vms->mtinst = (struct vm_reg){.code = 0x34A, .mode = 2, .val = 0};
    vms->regs[33] = vms->mtval2 = (struct vm_reg){.code = 0x34B, .mode = 2, .val = 0};

    // Process trapframe registers
    vms->regs[34] = vms->s0 = (struct vm_reg){.code = 0x000, .mode = 0, .val = 0};
    vms->regs[35] = vms->s1 = (struct vm_reg){.code = 0x001, .mode = 0, .val = 0};
    vms->regs[36] = vms->a0 = (struct vm_reg){.code = 0x010, .mode = 0, .val = 0};
    vms->regs[37] = vms->a1 = (struct vm_reg){.code = 0x011, .mode = 0, .val = 0};
    vms->regs[38] = vms->a2 = (struct vm_reg){.code = 0x100, .mode = 0, .val = 0};
    vms->regs[39] = vms->a3 = (struct vm_reg){.code = 0x101, .mode = 0, .val = 0};
    vms->regs[40] = vms->a4 = (struct vm_reg){.code = 0x110, .mode = 0, .val = 0};
    vms->regs[41] = vms->a5 = (struct vm_reg){.code = 0x111, .mode = 0, .val = 0};

    // Current execution privilege level
    vms->priv = 2; // 0 = U, 1 = S, 2 = M

    // boot the VM in the M mode by setting 11th and 12th bit of mstatus to 1
    vms->mstatus.val = vms->mstatus.val | (1 << 11) | (1 << 12);
    
}