PLAYER_UPDATE:
    # a0 = Object[0]
    # a1 = Object[1]
    # a2 = Object[3]
    # a3 = player data address

    # s0 = a0
    # s1 = a1
    # s2 = a2
    # s3 = a3

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

PLAYER_UPDATE_KEYPOLL:
	li t0, 0xFF200000 # t0 = endereço de controle do teclado
	lw t1, 0(t0) # t1 = conteudo de t0
	andi t2, t1, 1 # Mascara o primeiro bit (verifica sem tem tecla)
	beqz t2, PLAYER_MOVE_END # Se não tem tecla, então continua o jogo
	lw t1, 4(t0) # t1 = conteudo da tecla 
	
	li t0, 'w'
	beq t0, t1, PLAYER_MOVE_UP
	
	li t0, 's'
	beq t0, t1, PLAYER_MOVE_DOWN

    li t0, 'a'
	beq t0, t1, PLAYER_MOVE_LEFT

    li t0, 'd'
	beq t0, t1, PLAYER_MOVE_RIGHT

    j PLAYER_MOVE_END

PLAYER_MOVE_UP:
    # First get speed
    mv a0, s2
    jal ra, GET_OBJECT_INFO
    # a0 is the speed

    mv a1, a0
    mv a0, s0
    jal ra, MOVE_UP
    # a0 is the new position

    sw a0, 0(s3)

    j PLAYER_MOVE_END

PLAYER_MOVE_DOWN:
    # First get speed
    mv a0, s2
    jal ra, GET_OBJECT_INFO
    # a0 is the speed

    mv a1, a0
    mv a0, s0
    jal ra, MOVE_DOWN
    # a0 is the new position

    # If edge,
    #   move camera down
    #   change player position even further
    #   rerender the map

    sw a0, 0(s3)

    j PLAYER_MOVE_END

PLAYER_MOVE_RIGHT:
    # First get speed
    mv a0, s2
    jal ra, GET_OBJECT_INFO
    # a0 is the speed

    mv a1, a0
    mv a0, s0
    jal ra, MOVE_RIGHT
    # a0 is the new position

    sw a0, 0(s3)

    j PLAYER_MOVE_END

PLAYER_MOVE_LEFT:
    # First get speed
    mv a0, s2
    jal ra, GET_OBJECT_INFO
    # a0 is the speed

    mv a1, a0
    mv a0, s0
    jal ra, MOVE_LEFT
    # a0 is the new position

    sw a0, 0(s3)

    j PLAYER_MOVE_END

PLAYER_MOVE_END:
    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 20

    jalr zero, ra, 0