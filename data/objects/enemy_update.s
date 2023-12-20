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
    bne t0, t1, ENEMY_SKIP

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

    blt a6, a0, ENEMY_SKIP
    blt a7, a1, ENEMY_SKIP

    addi a0, a0, 320
    addi a1, a1, 240

    bgt a6, a0, ENEMY_SKIP
    bgt a7, a1, ENEMY_SKIP

    mv a0, s2
    jal ra, GET_OBJECT_INFO

    # If he is not invisible, skip
    li t0, 15
    bne a2, t0, SKIP_MAKE_ENEMY_VISIBLE

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

    lw a0, 12(s3)
    li a7, 34
    ecall

    j ENEMY_SKIP

SKIP_MAKE_ENEMY_VISIBLE:

    # If enemy is invisible skip
    mv a0, s2
    jal ra, GET_OBJECT_INFO    

    # Only move 16 in 16 frames
    la t0, CURRENT_FRAME
    lw t0, 0(t0)
    li t1, 64
    rem t0, t0, t1
    bne t0, zero, ENEMY_SKIP

    # j ENEMY_SKIP

ENEMY_MOVE:
    mv a0, s2
    jal ra, GET_OBJECT_INFO

    # Inventory goes until 255
    # Se o inventario estiver em 255, a gente muda
    # de direcao e reseta
    li t0, 250
    blt a1, t0, ENEMY_MOVE_IGNORE_CHANGE_MOVE

    xori a2, a2, 1
    # li a2, 1
    li a1, 0

    slli a0, a0, 24
    slli a1, a1, 16
    slli a2, a2, 12
    slli a3, a3, 8

    or t0, zero, a0
    or t0, t0, a1
    or t0, t0, a2
    or t0, t0, a3
    or t0, t0, a4

    sw t0, 12(s3)

    # mv a0, t0

    j ENEMY_SKIP

ENEMY_MOVE_IGNORE_CHANGE_MOVE:
    mv a0, s2
    jal ra, GET_OBJECT_INFO

    addi a1, a1, 1

    slli a0, a0, 24
    slli a1, a1, 16
    slli a2, a2, 12
    slli a3, a3, 8

    or t0, zero, a0
    or t0, t0, a1
    or t0, t0, a2
    or t0, t0, a3
    or t0, t0, a4

    sw t0, 12(s3)

    # Get player position
    # If player position = enemy position
    la t0, objects
    lw t0, 4(t0) # player position

    mv a0, t0
    jal ra, GET_OBJECT_POS

    mv a6, a0
    mv a7, a1

    mv a0, s0
    jal ra, GET_OBJECT_POS

    bne a6, a0, SKIP_PLAYER_DAMAGE
    bne a7, a1, SKIP_PLAYER_DAMAGE

    la t0, objects
    lw t0, 16(t0) # player info

    mv a0, t0
    jal ra, GET_OBJECT_INFO

    addi a4, a4, -20

    slli a0, a0, 24
    slli a1, a1, 16
    slli a2, a2, 12
    slli a3, a3, 8

    or t0, zero, a0
    or t0, t0, a1
    or t0, t0, a2
    or t0, t0, a3
    or t0, t0, a4

    la t1, objects
    sw t0, 16(t1)

    # mv a0, a4
    # li a7, 1
    # ecall

    # li a0, '\n'
    # li a7, 11
    # ecall

SKIP_PLAYER_DAMAGE:

    mv a0, s2
    jal ra, GET_OBJECT_INFO

    beq a2, zero, ENEMY_MOVE_RIGHT

ENEMY_MOVE_LEFT:
    mv a0, s2
    jal ra, GET_OBJECT_INFO

    li a1, 1
    mv a0, s0
    mv a2, zero
    jal ra, MOVE_LEFT

    sw a0, 0(s3)

    # li a7, 34
    # ecall
    
    # li a0, 'l'
    # li a7, 11
    # ecall

    # li a0, '\n'
    # li a7, 11
    # ecall

    j ENEMY_SKIP

ENEMY_MOVE_RIGHT:
    mv a0, s2
    jal ra, GET_OBJECT_INFO

    # mv a1, a0
    # mv a0, s0
    # li a2, 100000
    mv a0, s0
    li a1, 1
    li a2, 10
    jal ra, MOVE_RIGHT

    sw a0, 0(s3)

    # li a7, 34
    # ecall

    # li a0, 'r'
    # li a7, 11
    # ecall

    # li a0, '\n'
    # li a7, 11
    # ecall

ENEMY_SKIP:

    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 20

    jalr zero, ra, 0