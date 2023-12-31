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
    j PLAYER_MOVE_END

PLAYER_MOVE_DOWN:
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
    j PLAYER_MOVE_END

# PLAYER_MOVE_UPDATE:
#     add t4, zero, t3

#     slli t2, t2, 4
#     add t4, t4, t2

#     slli t1, t1, 8
#     add t4, t4, t1

#     slli t0, t0, 20
#     add t4, t4, t0

#     sw t4, 0(a3)

PLAYER_MOVE_END:
    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 20

    jalr zero, ra, 0