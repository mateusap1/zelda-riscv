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
	beqz t2, PLAYER_KEYPOLL_END # Se não tem tecla, então continua o jogo


li a2,120		# define o instrumento
    li a3,150		# define o volume
    li a0,100		# le o valor da nota
	li a1,250		# le a duracao da nota
    li a7,31
    # ecall


	lw t1, 4(t0) # t1 = conteudo da tecla 

	li t0, 'w'
	beq t0, t1, PLAYER_MOVE_UP
	
	li t0, 's'
	beq t0, t1, PLAYER_MOVE_DOWN

    li t0, 'a'
	beq t0, t1, PLAYER_MOVE_LEFT

    li t0, 'd'
	beq t0, t1, PLAYER_MOVE_RIGHT

    li t0, 'x'
	beq t0, t1, GO_TO_AREA_SECRETA

    li t0, 'z'
	beq t0, t1, GO_TO_MASMORRA
 
    j PLAYER_KEYPOLL_END

PLAYER_MOVE_UP:
    # First get speed
    mv a0, s2
    jal ra, GET_OBJECT_INFO
    # a0 is the speed

    mv a6, a0

    la t0, CAMERA_POSITION
    lw t0, 0(t0)

    # Split camera position
    mv a0, t0
    jal ra, GET_CAMERA_POSITIONS

    srli t0, a1, 4

    mv a2, t0
    mv a1, a6
    mv a0, s0
    jal ra, MOVE_UP
    # a0 is the new position
	
    mv a7, a0
    mv a6, a1
    
    # Get player position broken down
    mv a0, a0
    jal ra, GET_OBJECT_POS

    # Get current map index
    la t2, CURRENT_MAP
    lw t2, 0(t2)

    la t0, collision 
    addi t0, t0, 4 
    slli t1, t2, 2 
    add t0, t0, t1 
    
    lw t0, 0(t0)
    lw t1, 0(t0)
    addi t0, t0, 8
    mul t1, t1, a1
    add t1, t1, a0
    add t0, t0, t1

    lb t0, 0(t0)
    li t1, 1
    beq t0, t1, PLAYER_KEYPOLL_END
    
    mv a0, a7
    mv a1, a6
	
    sw a0, 0(s3)

    beq a1, zero, PLAYER_MOVE_UP_SKIP_CAMERA_MOVEMENT

    # Get player position broken down
    mv a0, a0
    jal ra, GET_OBJECT_POS

    # Se a nossa posiçao y é menor que o limite, para
    ble a1, zero, PLAYER_MOVE_UP_SKIP_CAMERA_MOVEMENT

    # Change player position
    addi a1, a1, -1
    # li a1, 14

    # Join them together
    slli a0, a0, 20
    slli a1, a1, 8
    slli a2, a2, 4

    or t0, zero, a0
    or t0, t0, a1
    or t0, t0, a2
    or t0, t0, a3

    # Save it
    sw t0, 0(s3)

    # Break down camera position
    la t0, CAMERA_POSITION
    lw t0, 0(t0)

    mv a0, t0
    jal ra, GET_CAMERA_POSITIONS

    addi a1, a1, -240

    # Join them together
    slli a0, a0, 16
    or t0, a0, a1

    la t1, CAMERA_POSITION
    sw t0, 0(t1)

    jal ra, START_MAP

PLAYER_MOVE_UP_SKIP_CAMERA_MOVEMENT:

    j PLAYER_KEYPOLL_END

PLAYER_MOVE_DOWN:
    # First get speed
    mv a0, s2
    jal ra, GET_OBJECT_INFO
    # a0 is the speed

    mv a6, a0

    la t0, CAMERA_POSITION
    lw t0, 0(t0)

    # Split camera position
    mv a0, t0
    jal ra, GET_CAMERA_POSITIONS

    addi t0, a1, 240
    srli t0, t0, 4
    addi t0, t0, -1

    mv a2, t0
    mv a1, a6
    mv a0, s0
    jal ra, MOVE_DOWN
    # a0 is the new position
    # a1 is whether we are in the edge
    
    mv a7, a0
    mv a6, a1
    
    # Get player position broken down
    mv a0, a0
    jal ra, GET_OBJECT_POS

    # Get current map index
    la t2, CURRENT_MAP
    lw t2, 0(t2)

    la t0, collision 
    addi t0, t0, 4 
    slli t1, t2, 2 
    add t0, t0, t1 
    
    lw t0, 0(t0)
    lw t1, 0(t0)
    addi t0, t0, 8
    mul t1, t1, a1
    add t1, t1, a0
    add t0, t0, t1

    lb t0, 0(t0)
    li t1, 1
    beq t0, t1, PLAYER_KEYPOLL_END
    
    mv a0, a7
    mv a1, a6

    sw a0, 0(s3)

    # # Get current map index
    # la t2, CURRENT_MAP
    # lw t2, 0(t2)

    beq a1, zero, PLAYER_MOVE_DOWN_SKIP_CAMERA_MOVEMENT

    # Get player position broken down
    mv a0, a0
    jal ra, GET_OBJECT_POS

    # Get current map index
    la t2, CURRENT_MAP
    lw t2, 0(t2)
    
    la t0, collision 
    addi t0, t0, 4 
    slli t1, t2, 2 
    add t0, t0, t1 
    
    lw t0, 0(t0)
    lw t1, 0(t0)
    lw t2, 4(t0)
    addi t0, t0, 8
    mul t1, t1, a1
    add t1, t1, a0
    add t0, t0, t1

    lb t0, 0(t0)
    mv t1, a0
    li a7, 1
    mv a0, t0
    ecall
    mv a0, t1
    
    # Get current map index
    la t2, CURRENT_MAP
    lw t2, 0(t2)

    la t0, maps # t0 = maps address
    addi t0, t0, 4 # skip maps num
    slli t1, t2, 3 # multiply index by 8
    add t0, t0, t1 # maps address + 4 + map_index * 8

    lw t0, 4(t0) # Endereço gamemap
    lw t0, 0(t0) # Altura gamemap
    addi t0, t0, -1

    # Se a nossa posiçao x é maior que o limite, para
    bge a1, t0, PLAYER_MOVE_DOWN_SKIP_CAMERA_MOVEMENT

    # Change player position
    addi a1, a1, 1

    # Join them together
    slli a0, a0, 20
    slli a1, a1, 8
    slli a2, a2, 4

    or t0, zero, a0
    or t0, t0, a1
    or t0, t0, a2
    or t0, t0, a3

    # Save it
    sw t0, 0(s3)

    # Break down camera position
    la t0, CAMERA_POSITION
    lw t0, 0(t0)

    mv a0, t0
    jal ra, GET_CAMERA_POSITIONS

    addi a1, a1, 240

    # Join them together
    slli a0, a0, 16
    or t0, a0, a1

    # li t0, 0x000000f0

    la t1, CAMERA_POSITION
    sw t0, 0(t1)

    jal ra, START_MAP

PLAYER_MOVE_DOWN_SKIP_CAMERA_MOVEMENT:

    j PLAYER_KEYPOLL_END

PLAYER_MOVE_RIGHT:
    # First get speed
    mv a0, s2
    jal ra, GET_OBJECT_INFO
    # a0 is the speed

    mv a6, a0

    la t0, CAMERA_POSITION
    lw t0, 0(t0)

    # Split camera position
    mv a0, t0
    jal ra, GET_CAMERA_POSITIONS

    addi t0, a0, 320
    srli t0, t0, 4
    addi t0, t0, -1

    mv a2, t0
    mv a1, a6
    mv a0, s0
    jal ra, MOVE_RIGHT
    # a0 is the new position
	
    mv a7, a0
    mv a6, a1
    
    # Get player position broken down
    mv a0, a0
    jal ra, GET_OBJECT_POS

    # Get current map index
    la t2, CURRENT_MAP
    lw t2, 0(t2)

    la t0, collision 
    addi t0, t0, 4 
    slli t1, t2, 2 
    add t0, t0, t1 
    
    lw t0, 0(t0)
    lw t1, 0(t0)
    addi t0, t0, 8
    mul t1, t1, a1
    add t1, t1, a0
    add t0, t0, t1

    lb t0, 0(t0)
    li t1, 1
    beq t0, t1, PLAYER_KEYPOLL_END
    
    mv a0, a7
    mv a1, a6
	
    sw a0, 0(s3)

    # Get current map index, then get gamemap width,
    # so that we know what is the limit
    # la t2, CURRENT_MAP
    # lw t2, 0(t2)
    
    beq a1, zero, PLAYER_MOVE_RIGHT_SKIP_CAMERA_MOVEMENT
    
    # la t2, CURRENT_MAP
    # lw t2, 0(t2)

    # Get player position broken down
    mv a0, a0
    jal ra, GET_OBJECT_POS

    # Get current map index
    la t2, CURRENT_MAP
    lw t2, 0(t2)
    
    la t0, maps # t0 = maps address
    addi t0, t0, 4 # skip maps num
    slli t1, t2, 3 # multiply index by 8
    add t0, t0, t1 # maps address + 4 + map_index * 8

    lw t0, 4(t0) # Endereço gamemap
    lw t0, 0(t0) # Largura gamemap
    addi t0, t0, -1

    # Se a nossa posiçao x é maior que o limite, para
    bge a0, t0, PLAYER_MOVE_RIGHT_SKIP_CAMERA_MOVEMENT

    # Change player position
    addi a0, a0, 1

    # Join them together
    slli a0, a0, 20
    slli a1, a1, 8
    slli a2, a2, 4

    or t0, zero, a0
    or t0, t0, a1
    or t0, t0, a2
    or t0, t0, a3

    # Save it
    sw t0, 0(s3)

    # Break down camera position
    la t0, CAMERA_POSITION
    lw t0, 0(t0)

    mv a0, t0
    jal ra, GET_CAMERA_POSITIONS

    addi a0, a0, 320

    # Join them together
    slli a0, a0, 16
    or t0, a0, a1

    la t1, CAMERA_POSITION
    sw t0, 0(t1)

    jal ra, START_MAP

PLAYER_MOVE_RIGHT_SKIP_CAMERA_MOVEMENT:

    j PLAYER_KEYPOLL_END

PLAYER_MOVE_LEFT:
    # First get speed
    mv a0, s2
    jal ra, GET_OBJECT_INFO
    # a0 is the speed

    mv a6, a0

    la t0, CAMERA_POSITION
    lw t0, 0(t0)

    # Split camera position
    mv a0, t0
    jal ra, GET_CAMERA_POSITIONS

    srli t0, a0, 4

    mv a2, t0
    mv a1, a6
    mv a0, s0
    jal ra, MOVE_LEFT
    # a0 is the new position
    
    mv a7, a0
    mv a6, a1
    
    # Get player position broken down
    mv a0, a0
    jal ra, GET_OBJECT_POS

    # Get current map index
    la t2, CURRENT_MAP
    lw t2, 0(t2)

    la t0, collision 
    addi t0, t0, 4 
    slli t1, t2, 2 
    add t0, t0, t1 
    
    lw t0, 0(t0)
    lw t1, 0(t0)
    addi t0, t0, 8
    mul t1, t1, a1
    add t1, t1, a0
    add t0, t0, t1

    lb t0, 0(t0)
    li t1, 1
    beq t0, t1, PLAYER_KEYPOLL_END
    
    mv a0, a7
    mv a1, a6

    sw a0, 0(s3)

    beq a1, zero, PLAYER_MOVE_LEFT_SKIP_CAMERA_MOVEMENT

    # Get player position broken down
    mv a0, a0
    jal ra, GET_OBJECT_POS

    # Get current map index
    la t2, CURRENT_MAP
    lw t2, 0(t2)
    
    la t0, collision 
    addi t0, t0, 4 
    slli t1, t2, 2 
    add t0, t0, t1 
    
    lw t0, 0(t0)
    lw t1, 0(t0)
    lw t2, 4(t0)
    addi t0, t0, 8
    mul t1, t1, a1
    add t1, t1, a0
    add t0, t0, t1

    lb t0, 0(t0)
    mv t1, a0
    li a7, 1
    mv a0, t0
    ecall
    mv a0, t1

    # Se a nossa posiçao x é menor que o limite, para
    beq a0, zero, PLAYER_MOVE_LEFT_SKIP_CAMERA_MOVEMENT

    # Change player position
    addi a0, a0, -1

    # Join them together
    slli a0, a0, 20
    slli a1, a1, 8
    slli a2, a2, 4

    or t0, zero, a0
    or t0, t0, a1
    or t0, t0, a2
    or t0, t0, a3

    # Save it
    sw t0, 0(s3)

    # HERE

    # Break down camera position
    la t0, CAMERA_POSITION
    lw t0, 0(t0)

    mv a0, t0
    jal ra, GET_CAMERA_POSITIONS

    addi a0, a0, -320

    # Join them together
    slli a0, a0, 16
    or t0, a0, a1

    la t1, CAMERA_POSITION
    sw t0, 0(t1)

    jal ra, START_MAP

PLAYER_MOVE_LEFT_SKIP_CAMERA_MOVEMENT:

    j PLAYER_KEYPOLL_END

GO_TO_MASMORRA:
    la t0, CURRENT_MAP
    li t1, 2
    sb t1, 0(t0)

    jal ra, START_MAP

    li t0, 0x00400400
    sw t0, 0(s3)

    j PLAYER_KEYPOLL_END

GO_TO_AREA_SECRETA:
    la t0, CURRENT_MAP
    li t1, 1
    sb t1, 0(t0)

    jal ra, START_MAP

    li t0, 0x00400400
    sw t0, 0(s3)

    j PLAYER_KEYPOLL_END

PLAYER_KEYPOLL_END:
    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 20

    jalr zero, ra, 0
