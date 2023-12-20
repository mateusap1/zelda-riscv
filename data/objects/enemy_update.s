ENEMY_UPDATE:
    # a0 = Object[0]
    # a1 = Object[1]
    # a2 = Object[3]
    # a3 = enemy data address

    addi sp, sp, -20
    sw s3, 16(sp)
    sw s2, 12(sp)
    sw s1, 8(sp)
    sw s0, 4(sp)
    sw ra, 0(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3

    # If our map is masmorra, make him visible
    la t0, CURRENT_MAP
    lb t0, 0(t0)

    li t1, 2
    bne t0, t1, SKIP_MAKE_ENEMY_VISIBLE

    mv a0, s2
    jal ra, GET_OBJECT_INFO

    li s2, 0

    slli a0, a0, 24
    slli a1, a1, 16
    slli a2, s2, 12
    slli a3, a3, 8

    or t0, zero, a0
    or t0, t0, a1
    or t0, t0, a2
    or t0, t0, a3
    or t0, t0, a4

    sw t0, 12(s3)

SKIP_MAKE_ENEMY_VISIBLE:

    # If enemy is invisible skip
    mv a0, s2
    jal ra, GET_OBJECT_INFO    

    li t0, 1 # invisible animation index
    beq s2, t0, ENEMY_SKIP

ENEMY_MOVE:
    # Get current state from object[3]

    # a0 is position
    # a1 is speed
    # a2 is edge
    # MOVE_RIGHT

ENEMY_SKIP:

    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 20

    jalr zero, ra, 0