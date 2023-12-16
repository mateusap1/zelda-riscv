PLAYER_UPDATE:
    # a0 = Object[0]
    # a1 = Object[1]
    # a2 = Object[3]
    # a3 = player data address

    # li t2, 0x11000000
    # and t2, a2, t2
    # srli t2, t2, 8 # t2 = speed

    # li t3, 0x011
    # and t3, a2, t3
    # srli t3, t3, 8 # t3 = hp

    # j PLAYER_MOVE_UPDATE

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

PLAYER_MOVE_UP:
    li t0, 0xf00000
    and t0, a0, t0
    srli t0, t0, 20 # t0 = tilePosX

    li t1, 0x0fff00
    and t1, a0, t1
    srli t1, t1, 8 # t1 = tilePosY

    li t2, 0x0f0
    and t2, a0, t2
    srli t2, t2, 4 # t2 = offsetX

    li t3, 0x0f
    and t3, a0, t3 # t3 = offsetY

    li t4, 0xff000000
    and t4, a2, t4
    srli t4, t4, 24 # t4 = speed

PLAYER_MOVE_UP_OFFSET:
    # Subtrai do offsetY - speed % 16
    # Subtrai do posY speed / 16

    li t5, 16
    remu t5, t4, t5
    sub t3, t3, t5

    li t5, 16
    div t5, t4, t5
    sub t1, t1, t5

    # blt t1, zero, PLAYER_MOVE_UP_EDGE
    bge t3, zero, PLAYER_MOVE_UPDATE

PLAYER_MOVE_UP_NEGATIVE_OFFSET:
    # Se offsetY < 0,
    #   offset = 16 + offset; 
    #   posY -= 1;

    li t5, 16
    add t3, t5, t3
    addi t1, t1, -1

    bge t1, zero, PLAYER_MOVE_UPDATE

PLAYER_MOVE_UP_EDGE:
    # Se posY < 0,
    #   offsetY = 0;
    #   posY = 0;

    mv t1, zero
    mv t3, zero

    j PLAYER_MOVE_UPDATE

PLAYER_MOVE_DOWN:
    li t0, 0xf00000
    and t0, a0, t0
    srli t0, t0, 20 # t0 = tilePosX

    li t1, 0x0fff00
    and t1, a0, t1
    srli t1, t1, 8 # t1 = tilePosY

    li t2, 0x0f0
    and t2, a0, t2
    srli t2, t2, 4 # t2 = offsetX

    li t3, 0x0f
    and t3, a0, t3 # t3 = offsetY

    li t4, 0xff000000
    and t4, a2, t4
    srli t4, t4, 24 # t4 = speed

PLAYER_MOVE_DOWN_OFFSET:
    # Adiciona ao offsetY speed % 16
    # Adiciona a0 posY speed / 16

    li t5, 16
    remu t5, t4, t5
    add t3, t3, t5

    li t5, 16
    divu t5, t4, t5
    add t1, t1, t5

    li t5, 14
    bge t1, t5, PLAYER_MOVE_DOWN_EDGE

    li t5, 16
    blt t3, t5, PLAYER_MOVE_UPDATE

PLAYER_MOVE_DOWN_BIG_OFFSET:
    # Se offsetY >= 16,
    #   offsetY = offsetY - 16; 
    #   posY += 1;

    li t5, 16
    sub t3, t3, t5
    addi t1, t1, 1

    li t5, 14
    blt t1, t5, PLAYER_MOVE_UPDATE

PLAYER_MOVE_DOWN_EDGE:
    # Se posY >= 14,
    #   offsetY = 0;
    #   posY = 14;

    li t1, 14
    mv t3, zero

    j PLAYER_MOVE_UPDATE

PLAYER_MOVE_RIGHT:
    li t0, 0xf00000
    and t0, a0, t0
    srli t0, t0, 20 # t0 = tilePosX

    li t1, 0x0fff00
    and t1, a0, t1
    srli t1, t1, 8 # t1 = tilePosY

    li t2, 0x0f0
    and t2, a0, t2
    srli t2, t2, 4 # t2 = offsetX

    li t3, 0x0f
    and t3, a0, t3 # t3 = offsetY

    li t4, 0xff000000
    and t4, a2, t4
    srli t4, t4, 24 # t4 = speed

PLAYER_MOVE_RIGHT_OFFSET:
    # Adiciona ao offsetX speed % 16
    # Adiciona a0 posX speed / 16

    li t5, 16
    remu t5, t4, t5
    add t2, t2, t5

    li t5, 16
    divu t5, t4, t5
    add t0, t0, t5

    li t5, 19
    bge t0, t5, PLAYER_MOVE_RIGHT_EDGE

    li t5, 16
    blt t2, t5, PLAYER_MOVE_UPDATE

PLAYER_MOVE_RIGHT_BIG_OFFSET:
    # Se offsetX >= 16,
    #   offsetX = offsetX - 16; 
    #   posX += 1;

    li t5, 16
    sub t2, t2, t5
    addi t0, t0, 1

    li t5, 19
    blt t0, t5, PLAYER_MOVE_UPDATE

PLAYER_MOVE_RIGHT_EDGE:
    # Se posX >= 19,
    #   offsetX = 0;
    #   posX = 19;

    li t0, 19
    mv t2, zero

    j PLAYER_MOVE_UPDATE

PLAYER_MOVE_LEFT:
    li t0, 0xf00000
    and t0, a0, t0
    srli t0, t0, 20 # t0 = tilePosX

    li t1, 0x0fff00
    and t1, a0, t1
    srli t1, t1, 8 # t1 = tilePosY

    li t2, 0x0f0
    and t2, a0, t2
    srli t2, t2, 4 # t2 = offsetX

    li t3, 0x0f
    and t3, a0, t3 # t3 = offsetY

    li t4, 0xff000000
    and t4, a2, t4
    srli t4, t4, 24 # t4 = speed

PLAYER_MOVE_LEFT_OFFSET:
    # Subtrai do offsetX speed % 16
    # Subtrai do posX speed / 16

    li t5, 16
    remu t5, t4, t5
    sub t2, t2, t5

    li t5, 16
    divu t5, t4, t5
    sub t0, t0, t5

    bge t2, zero, PLAYER_MOVE_UPDATE

PLAYER_MOVE_LEFT_NEGATIVE_OFFSET:
    # Se offsetX < 0,
    #   offsetX = 16 + offsetX; 
    #   posX -= 1;

    li t5, 16
    add t2, t5, t2
    addi t0, t0, -1

    bge t0, zero, PLAYER_MOVE_UPDATE

PLAYER_MOVE_LEFT_EDGE:
    # Se posX < 0,
    #   offsetX = 0;
    #   posX = 0;

    mv t0, zero
    mv t2, zero

PLAYER_MOVE_UPDATE:

    add t4, zero, t3

    slli t2, t2, 4
    add t4, t4, t2

    slli t1, t1, 8
    add t4, t4, t1

    slli t0, t0, 20
    add t4, t4, t0

    sw t4, 0(a3)

PLAYER_MOVE_END:

    # li a7, 10
    # ecall

    # mv a0, a3
    # li a7, 1
    # ecall

    # li t4, 0x01101100
    # sw t4, 0(a3)

    jalr zero, ra, 0