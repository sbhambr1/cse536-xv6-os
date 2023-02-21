# _entry should be the first function invoked when
# the QEMU CPU starts executing. 

.section .text
.global _entry
_entry:
        # CSE 536: Task 2.3
        # Load the end of bl_stack to the sp register
        
        la sp, bl_stack
        li a0, 1024*4
        csrr a1, mhartid
        addi a1, a1, 1
        mul a0, a0, a1
        add sp, sp, a0

        call start

.global spin
spin:
        j spin