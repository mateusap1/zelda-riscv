.data

# Gamemaps
.include "data/maps/gamemap/overworld_gamemap.s"
.include "data/maps/gamemap/underworld_gamemap.s"

# Tilemaps
.include "data/maps/tilemap/overworld_tilemap.s"

# Map
.include "data/maps.s"

# Sprites
.include "sprites/player.s"

# Animations
.include "data/animations/player_animation.s"

# Objects
.include "data/objects/player_object.s"
.include "data/objects.s"

.text

SETUP:
    # ==========================
    # s0 = Camera position em termos de 320x240
    # s1 = Current map index
    # ==========================

    li a0, 0
    li a1, 0
    li a2, 160
    li a3, 120

    jal ra, RENDER_MAP

END: j END

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

    # Adiciona 16 * index do tilemap
    li t2, 16
    mul t2, a4, t2

    # Encontramos o inicio da imagem no tilemap
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

# ===================== PRINT =====================

# Carrega um sprite na tela

# a0 = endereço imagem
# a1 = x
# a2 = y
# a3 = frame (0 ou 1)

# t0 = endereço do bitmap display
# t1 = endereço de imagem
# t2 = contador da linha
# t3 = contador da coluna
# t4 = largura
# t5 = altura

PRINT:
    # Setup
    li t0, 0xFF0
    add t0, t0, a3
    slli t0, t0, 20

    add t0, t0, a1

    li t1, 320
    mul t1, t1, a2
    add t0, t0, t1

    addi t1, a0, 8

    mv t2, zero
    mv t3, zero

    lw t4, 0(a0)
    lw t5, 4(a0)

PRINT_LINHA:
    lw t6, 0(t1)
    sw t6, 0(t0)

    addi t0, t0, 4
    addi t1, t1, 4

    addi t3, t3, 4
    blt t3, t4, PRINT_LINHA

NEXT_LINHA:
    addi t2, t2, 1
    mv t3, zero

    li t6, 320
    sub t6, t6, t4
    add t0, t0, t6

    blt t2, t5, PRINT_LINHA

PRINT_FIM:
    jalr zero, ra, 0

# =================================================

# Objects Update
.include "data/objects/player_update.s"