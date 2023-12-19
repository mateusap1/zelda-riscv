# ======= Functions =======
# GET_OBJECT_RENDER_COORDS
# GET_TILE_RENDER_COORDS
# GET_TILE_INDEX
# GET_OBJECT_SPRITE_TILEMAP
# RENDER_OBJECT
# RENDER_TILE
# RENDER_BACKGROUND_TILES
# RENDER_MAP
# FIND_GAMEMAP_TILE
# PRINT_TILE
# =========================

# ===================== GET_OBJECT_RENDER_COORDS =====================
# a0 = camera position
# a1 = player position

# s0 = player position
# s1 = camera position x
# s2 = camera position y

# Returns
# a0 = render coord x
# a1 = render coord y

GET_OBJECT_RENDER_COORDS:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw s0, 0(sp)

    mv s0, a1

    mv a0, a0 # Redundant
    jal ra, GET_CAMERA_POSITIONS
    
    mv s1, a0 # s1 is now the camera position x
    mv s2, a1 # s2 is now the camera position y

    mv a0, s0
    jal ra, GET_OBJECT_POS

    # a0 = Tile Pos X
    # a1 = Tile Pos Y
    # a2 = Tile Offset X
    # a3 = Tile Offset Y

    slli t0, a0, 4 # t0 = tilePosX * 16
    sub t0, t0, s1 # t0 = tilePosX * 16 - camPosX
    add t0, t0, a2 # Render coord x = t0 + playerOffsetX

    slli t1, a1, 4 # t1 = tilePosY * 16
    sub t1, t1, s2  # t1 = tilePosY * 16 - camPosY
    add t1, t1, a3 # Render coord y = t0 + playerOffsetY

    mv a0, t0
    mv a1, t1

    lw ra, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 16

    jalr zero, ra, 0

# =====================================================

# ===================== GET_TILE_RENDER_COORDS =====================
# a0 = camera position x
# a1 = camera position y
# a2 = tilePosX
# a3 = tilePosY

# Returns
# a0 = render coord x
# a1 = render coord y
# a2 = offset x
# a3 = offset y

GET_TILE_RENDER_COORDS:
    srli t0, a2, 4 # t0 = tilePosX * 16
    sub t0, t0, a0  # Render coord x = tilePosX * 16 - camPosX

    srli t1, a3, 4 # t1 = tilePosY * 16
    sub t1, t1, a1  # Render coord y = tilePosY * 16 - camPosY

    li t2, 16
    rem t2, a0, t2 # OffX = camPosX % 16

    li t3, 16
    rem t3, a1, t3 # OffY = camPosY % 16

    mv a0, t0
    mv a1, t1
    mv a2, t2
    mv a3, t3

    jalr zero, ra, 0

# =====================================================

# ===================== GET_TILE_INDEX =====================
# a0 = tilemap address
# a1 = tile position x
# a2 = tile position y

GET_TILE_INDEX:
    lw t0, 0(a0) # Tilemap width

    # ====== Get tile index address ======
    addi a0, a0, 8 # ignore tilemap size info
    mul t2, a2, t0 # width * tileposy
    add a0, a0, t2 # tile index address += width * tileposy
    add a0, a0, a1 # tile index address += tileposx
    # ====================================

    lw a0, 0(a0) # load tile index from address

    jalr zero, ra, 0

# =====================================================

# ========== GET_OBJECT_SPRITE_TILEMAP ==========
# a0 = object animation address
# a1 = animation select index
# a2 = animation step index

GET_OBJECT_SPRITE_TILEMAP:
    slli t1, a1, 2
    add t2, a0, t1

    lw a0, 4(t2) # Skip size

    jalr zero, ra, 0
# =======================================

# ========== RENDER_OBJECT ==========
# a0 = object position - Objects[i][0]
# a1 = object animation address - Objects[i][1]
# a2 = object info - Objects[1][2]
# a3 = camera position
# a4 = frame

# s0 = a0
# s1 = a1
# s2 = a2
# s3 = a3
# s4 = a4
# s5 = animation select index
# s6 = animation step index
# s7 = object sprite address
# s8 = render position x
# s9 = render position y

RENDER_OBJECT:
    addi sp, sp, -44
    sw s9, 40(sp)
    sw s8, 36(sp)
    sw s7, 32(sp)
    sw s6, 28(sp)
    sw s5, 24(sp)
    sw s4, 20(sp)
    sw s3, 16(sp)
    sw s2, 12(sp)
    sw s1, 8(sp)
    sw s0, 4(sp)
    sw ra, 0(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s4, a4

    mv a0, s2
    jal ra, GET_OBJECT_INFO
    mv s5, a2
    mv s6, a3

    mv a0, s1
    mv a1, s5
    mv a2, s6
    jal ra, GET_OBJECT_SPRITE_TILEMAP
    mv s7, a0

    # li s6, 0

    mv a0, s3
    mv a1, s0
    jal ra, GET_OBJECT_RENDER_COORDS
    mv s8, a0
    mv s9, a1

    mv a0, s7
    mv a1, s8
    mv a2, s9
    mv a3, s4
    mv a4, s6
    li a5, 0
    li a6, 0
    jal ra, PRINT_TILE

    lw s9, 40(sp)
    lw s8, 36(sp)
    lw s7, 32(sp)
    lw s6, 28(sp)
    lw s5, 24(sp)
    lw s4, 20(sp)
    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 44

    jalr zero, ra, 0
# ===================================

# =============== RENDER_TILE ===============
# a0 = camera position x
# a1 = camera position y
# a2 = tile position x
# a3 = tile position y
# a4 = gamemap address
# a5 = tilemap address
# a6 = frame
RENDER_TILE:
    addi sp, sp, -4
    sw ra, 0(sp)

    # First calculate offset x and y
    li t0, 16
    rem t0, a0, t0

    li t1, 16
    rem t1, a1, t1

    slli t2, a2, 4
    sub t2, t2, a0

    bge t2, zero, RENDER_TILE_NOT_ZERO_X
    mv t2, zero
RENDER_TILE_NOT_ZERO_X:
    slli t3, a3, 4
    sub t3, t3, a1

    bge t3, zero, RENDER_TILE_NOT_ZERO_Y
    mv t3, zero
RENDER_TILE_NOT_ZERO_Y:

    # Find tile
    li t4, 20
    mul t4, a3, t4 # tile pos y * gamemap width
    add t4, t4, a4
    add t4, t4, a2

    lb t4, 8(t4) # the tile index

    # If render position x is not zero and not
    # greater than 304, we change it to zero

    li t5, 304
    bgt t0, t5, RENDER_TILE_OFFSET_X_NOT_ZERO
    beq t0, zero, RENDER_TILE_OFFSET_X_NOT_ZERO
    mv t0, zero
RENDER_TILE_OFFSET_X_NOT_ZERO:

    li t5, 224
    bgt t1, t5, RENDER_TILE_OFFSET_Y_NOT_ZERO
    beq t1, zero, RENDER_TILE_OFFSET_Y_NOT_ZERO
    mv t1, zero
RENDER_TILE_OFFSET_Y_NOT_ZERO:

    # a0 = endereço tilemap
    # a1 = render position x
    # a2 = render position y
    # a3 = frame (0 ou 1)
    # a4 = tile index
    # a5 = tile offset x
    # a6 = tile offset y

    mv a0, a5
    mv a1, t2
    mv a2, t3
    mv a3, a6
    mv a4, t4
    mv a5, t0
    mv a6, t1
    jal ra, PRINT_TILE

    lw ra, 0(sp)
    addi sp, sp, 4

    jalr zero, ra, 0
# ===========================================

# ================ RENDER_BACKGROUND_TILES ================

# a0 = tilemap address
# a1 = gamemap address
# a2 = frame
# a3 = tile position
# a4 = camera position

# s0 = a0 = tilemap address
# s1 = a1 = gamemap address
# s2 = a2 = frame
# s3 = cam position x
# s4 = cam position y
# s5 = tile position x
# s6 = tile position y
# s7 = offset x
# s8 = offset y

RENDER_BACKGROUND_TILES:
    addi sp, sp, -40
    sw ra, 36(sp)
    sw s8, 32(sp)
    sw s7, 28(sp)
    sw s6, 24(sp)
    sw s5, 20(sp)
    sw s4, 16(sp)
    sw s3, 12(sp)
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw s0, 0(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2

    # Find out camera position
    mv a0, a4
    jal ra, GET_CAMERA_POSITIONS
    mv s3, a0
    mv s4, a1
    
    mv a0, a3
    jal ra, GET_OBJECT_POS
    mv s5, a0
    mv s6, a1
    mv s7, a2
    mv s8, a3

RENDER_BACKGROUND_CURRENT_TILE:
    mv a0, s3
    mv a1, s4 
    mv a2, s5  
    mv a3, s6 
    mv a4, s1
    mv a5, s0
    mv s6, s2
    jal ra, RENDER_TILE

RENDER_BACKGROUND_RIGHT_TILE:
    # If offest x > 0: render right tile
    beq s7, zero, RENDER_BACKGROUND_DOWN_TILE

    mv a0, s3
    mv a1, s4 
    addi a2, s5, 1
    mv a3, s6 
    mv a4, s1
    mv a5, s0
    mv s6, s2
    jal ra, RENDER_TILE

RENDER_BACKGROUND_DOWN_TILE:
    # If offest y > 0: render right tile
    beq s8, zero, RENDER_BACKGROUND_END

    mv a0, s3
    mv a1, s4 
    mv a2, s5
    addi a3, s6, 1
    mv a4, s1
    mv a5, s0
    mv s6, s2
    jal ra, RENDER_TILE

RENDER_BACKGROUND_DIAGONAL_TILE:
    # If offest y == 0: skip
    beq s8, zero, RENDER_BACKGROUND_END

    # If offest x == 0: skip
    beq s7, zero, RENDER_BACKGROUND_END

    mv a0, s3
    mv a1, s4 
    addi a2, s5, 1
    addi a3, s6, 1
    mv a4, s1
    mv a5, s0
    mv s6, s2
    jal ra, RENDER_TILE

RENDER_BACKGROUND_END:
    lw ra, 36(sp)
    lw s8, 32(sp)
    lw s7, 28(sp)
    lw s6, 24(sp)
    lw s5, 20(sp)
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 40

    jalr zero, ra, 0

# =============================================

# ================ RENDER_MAP ================

# a0 = map index => vai nos dar acesso ao tilemap e gamemap
# a1 = frame (0 ou 1)
# a2 = pos x do player
# a3 = pos y do player

# s0 = i (coord x do bitmap)
# s1 = j (coord y do bitmap)
# s2 = a0 = map index
# s3 = a1 = frame
# s4 = a2 = pos x do player
# s5 = a3 = pos y do player
# s6 = tilemap address
# s7 = gamemap address
# s8 = gamemap width
# s9 = offsetX
# s10 = offsetY

RENDER_MAP:
    addi sp, sp, -44
    sw ra, 44(sp)
    sw s10, 40(sp)
    sw s9, 36(sp)
    sw s8, 32(sp)
    sw s7, 28(sp)
    sw s6, 24(sp)
    sw s5, 20(sp)
    sw s4, 16(sp)
    sw s3, 12(sp)
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw s0, 0(sp)

    mv s2, a0
    mv s3, a1
    mv s4, a2
    mv s5, a3

    # Figure out based on array the gamemap address
    la t0, maps
    addi t0, t0, 4
    slli t1, a0, 3
    add t0, t0, t1

    lw s6, 0(t0)
    lw s7, 4(t0)
    lw s8, 0(s7)

RENDER_MAP_LOOP_Y_START:
    mv s1, zero

RENDER_MAP_LOOP_Y:
    li t0, 240
    bge s1, t0, RENDER_MAP_LOOP_Y_END

    # =========== RENDER_MAP_LOOP_Y_INNER ===========

    RENDER_MAP_LOOP_X_START:
        mv s0, zero

    RENDER_MAP_LOOP_X:
        li t0, 320
        bge s0, t0, RENDER_MAP_LOOP_X_END

        # =========== RENDER_MAP_LOOP_X_INNER ===========

        mv a0, s4
        mv a1, s5
        mv a2, s0
        mv a3, s1
        mv a4, s6
        mv a5, s7
        mv a6, s8
        jal ra, FIND_GAMEMAP_TILE

        mv t0, a0 # t0 = tile index
        mv s9, a3 # t1 = offsetX
        mv s10, a4 # t2 = offsetY

        mv a0, s6
        mv a1, s0
        mv a2, s1
        mv a3, s3
        mv a4, t0
        mv a5, s9
        mv a6, s10

        jal ra, PRINT_TILE

        # Calcular index i da próxima iteração
        li t0, 16
        sub t0, t0, s9
        add s0, s0, t0

        j RENDER_MAP_LOOP_X

        # ===============================================
    
    RENDER_MAP_LOOP_X_END:

    li t0, 16
    sub t0, t0, s10
    add s1, s1, t0

    j RENDER_MAP_LOOP_Y

    # ===============================================

RENDER_MAP_LOOP_Y_END:

    lw ra, 44(sp)
    lw s10, 40(sp)
    lw s9, 36(sp)
    lw s8, 32(sp)
    lw s7, 28(sp)
    lw s6, 24(sp)
    lw s5, 20(sp)
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)

    addi sp, sp, 44

    jalr zero, ra, 0

# ============================================

# ================= FIND_GAMEMAP_TILE =================

# Find gamemap tile when player is at (x, y) and we are
# rendering the pixel (i, j)
# Returns (a0=tile_index, a1=posxTile, a2=posyTile, a3=offsetX, a4=offsetYx)

# a0 = posx do player
# a1 = posy do player
# a2 = coordenada x do bitmap
# a3 = coordenada y do bitmap
# a4 = tilemap address
# a5 = gamemap address
# a6 = gamemap width

FIND_GAMEMAP_TILE:

    # MAX(posx, 160)
    li t0, 160
    bgt a0, t0, FIND_GAMEMAP_TILE_X_GREATER
    mv a0, t0

FIND_GAMEMAP_TILE_X_GREATER:

    # MAX(posy, 120)
    li t0, 120
    bgt a1, t0, FIND_GAMEMAP_TILE_Y_GREATER
    mv a1, t0

FIND_GAMEMAP_TILE_Y_GREATER:

    # Calcular posicao x equivalente do gamemap
    # para a corrdenada i atual
    li t0, 160
    sub t2, a0, t0 # posx do player - 160
    add t2, t2, a2 # t2 = posX do gamemap 

    # Calcular posicao y equivalente do gamemap
    # para a corrdenada j atual
    li t0, 120
    sub t3, a1, t0 # posy do player - 120
    add t3, t3, a3 # t3 = posY do gamemap 

    # t2 = posX do gamemap
    # t3 = posY do gamemap

    li t0, 16
    remu t4, t2, t0 # t4 = offsetX
    remu t5, t3, t0 # t5 = offsetY

    # O problema é que o gamemap é dividido por 16
    # Então dividir posX e posY por 16
    srli t2, t2, 4 # posX
    srli t3, t3, 4 # posY

    # Tile index vai estar localizado no gamemap na
    # localização GAMEMAP_ADDRESS + posX + GAMEMAP.width * posY
    mul t0, a6, t3 # GAMEMAP.width * posY
    add t1, a5, t0
    add t1, t1, t2
    addi t1, t1, 8 # t1 é o endereço do index

    lbu a0, 0(t1) # a0 é o index
    mv a1, t2
    mv a2, t3
    mv a3, t4
    mv a4, t5

    jalr zero, ra, 0

# =====================================================

# ===================== PRINT_TILE =====================

# Carrega um tile na tela assumindo 16x16
# Offset precisa ser divisivel por 4

# a0 = endereço tilemap
# a1 = render position x
# a2 = render position y
# a3 = frame (0 ou 1)
# a4 = tile index
# a5 = tile offset x
# a6 = tile offset y

# t0 = endereço do bitmap display
# t1 = endereço de imagem
# t2 = contador da linha
# t3 = contador da coluna
# t4 = largura
# t5 = altura
# t6 = livre

PRINT_TILE:
    # ========== Encontrar posição do bitmap display ==========
    li t0, 0xFF0
    add t0, t0, a3
    slli t0, t0, 20

    add t0, t0, a1

    li t1, 320
    mul t1, t1, a2
    add t0, t0, t1
    # =========================================================

    # Tamanho da imagem w e h
    lw t4, 0(a0) # largura
    lw t5, 4(a0) # altura

    addi t1, a0, 8 # Começo da imagem do tilemap

    li t2, 9
    rem t2, a4, t2
    slli t2, t2, 4
    add t1, t1, t2

    li t2, 9
    div t2, a4, t2
    slli t2, t2, 4
    mul t2, t2, t4
    add t1, t1, t2 

    # Pulamos o offset também
    add t1, t1, a5 # Pulando o offset x

    mul t2, t4, a6
    add t1, t1, t2 # Pulando o offset y

    mv t2, a6
    mv t3, a5

PRINT_TILE_LINHA:
    lw t6, 0(t1)
    sw t6, 0(t0)

    addi t0, t0, 4 # endereço bitmap + 4
    addi t1, t1, 4 # endereço imagem + 4 

    addi t3, t3, 4 # contador coluna + 4

    li t6, 16
    blt t3, t6, PRINT_TILE_LINHA # coluna < 16

PRINT_TILE_NEXT_LINHA:
    addi t2, t2, 1 # contador linha + 1
    mv t3, a5 # contador coluna = offset x 

    li t6, 320
    add t0, t0, t6 # endereço display += 320

    li t6, 16
    sub t0, t0, t6 # endereço display -= 16
    add t0, t0, a5 # endereço display += offset x

    add t1, t1, t4 # endereço image += image.width

    li t6, 16
    sub t1, t1, t6 # endereço image -= 16
    add t1, t1, a5 # endereço image += offset x

    li t6, 16
    blt t2, t6, PRINT_TILE_LINHA

PRINT_TILE_FIM:
    jalr zero, ra, 0

# ========================================================