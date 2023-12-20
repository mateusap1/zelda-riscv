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

    # j SKIP_MAKE_ENEMY_VISIBLE

    # If camera is not here, skip
    mv a0, s0
    jal ra, GET_OBJECT_POS

    mv a6, a0
    mv a7, a1

    la t0, CAMERA_POSITION
    lw t0, 0(t0)

    mv a0, t0
    jal ra, GET_CAMERA_POSITIONS

    slli a6, a6, 4
    slli a7, a7, 4

    blt a6, a0, SKIP_MAKE_ENEMY_VISIBLE
    blt a7, a1, SKIP_MAKE_ENEMY_VISIBLE

    addi a0, a0, 320
    addi a1, a1, 240

    bgt a6, a0, SKIP_MAKE_ENEMY_VISIBLE
    bgt a7, a1, SKIP_MAKE_ENEMY_VISIBLE

    mv a0, s2
    jal ra, GET_OBJECT_INFO

    li t0, 0

    slli a0, a0, 24
    slli a1, a1, 16
    slli a2, t0, 12
    slli a3, a3, 8

    or t0, zero, a0
    or t0, t0, a1
    or t0, t0, a2
    or t0, t0, a3
    or t0, t0, a4

    sw t0, 12(s3)

    # lw a0, 12(s3)
    # li a7, 34
    # ecall

    j ENEMY_SKIP

SKIP_MAKE_ENEMY_VISIBLE:

    # If enemy is invisible skip
    mv a0, s2
    jal ra, GET_OBJECT_INFO    

    li t0, 0 # invisible animation index
    beq s2, t0, ENEMY_SKIP

    j ENEMY_SKIP

ENEMY_MOVE:
    # Get current state from object[3]

    # If enemy is invisible skip
    mv a0, s2
    jal ra, GET_OBJECT_INFO

    # Inventory goes until 255
    # Se o inventario estiver em 255, a gente muda
    # de direcao e reseta
    li t0, 255
    blt a1, t0, ENEMY_MOVE_IGNORE_CHANGE_MOVE

    xori a2, a2, 1

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

ENEMY_MOVE_IGNORE_CHANGE_MOVE:
    mv a0, s2
    jal ra, GET_OBJECT_INFO

    addi a1, a1, 1

    slli a0, a0, 24
    slli a1, a1, 16
    slli a2, s2, 12
    slli a3, a3, 8

    or t0, zero, a0
    or t0, t0, a1
    or t0, t0, a2
    or t0, t0, a3
    or t0, t0, a4

    mv a0, t0
    li a7, 34
    ecall

    sw t0, 12(s3)

    mv a0, s2
    jal ra, GET_OBJECT_INFO

    # If animation is 0, move right
    # Else, move left

    beq a2, zero, ENEMY_MOVE_RIGHT

ENEMY_MOVE_LEFT:
    mv a1, a0
    mv a0, s0
    mv a2, zero
    jal ra, MOVE_LEFT

    j ENEMY_SKIP

ENEMY_MOVE_RIGHT:
    mv a1, a0
    mv a0, s0
    li a2, 1000
    jal ra, MOVE_LEFT

ENEMY_SKIP:

    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 20

    jalr zero, ra, 0