 #####################################################################
 # Quick and dirty bios dump utility..
 # Distributed as is
 #                      -pukko


	.file	1 "asm.s"
# .set nomips16
.set noat
# .data 1
.p2align 4
.insn
.p2align 4
.set noreorder

##############################

        .globl  k_RFU116
        .ent    k_RFU116
k_RFU116:
        li      $3, 116
        syscall
        jr      $31
        nop
        .end    k_RFU116


##############################        
        .globl  k_readMem
        .ent    k_readMem
k_readMem:
        li $3, 254
        syscall
        jr $31
        nop
        .end k_readMem


##############################
        .globl  su_readMem
        .ent    su_readMem
su_readMem:
        # $2 = $v0, $4 = $a0..
        lw      $2, 0($4)
        jr      $31
        nop
        .end    su_readMem
