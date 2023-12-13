.data
.include "assets/overworld_map.s"
.include "assets/tilemap_overworld.s"
.include "assets/char.s"
.include "assets/frogger.s"

.text
SETUP:
    # ==========================
    # s0 = PosX player
    # s1 = PosY player
    # s2 = Current Map address
    # s3 = Use freely 
    # s4 = Use freely
    # ==========================

# =============== TEST_PRINT ===============

# a0 = endereço imagem
# a1 = render position x
# a2 = render position y
# a3 = frame (0 ou 1)
# a4 = tile index
# a5 = tile offset x
# a6 = tile offset y

la a0, tilemap_overworld
mv a1, zero
mv a2, zero
mv a3, zero
li a4, 2
li a5, 0
li a6, 0

jal ra, PRINT_TILE


la a0, tilemap_overworld
li a1, 16
li a2, 0
mv a3, zero
li a4, 2
li a5, 8
li a6, 8

jal ra, PRINT_TILE

# ==========================================

END_2: j END_2


RENDER_MAP_LOOP_Y_START:
    addi s3, zero, 0 # s3 = 0 (current index y)

RENDER_MAP_LOOP_Y:
    li t0, 240
    beq s3, t0, RENDER_MAP_LOOP_Y_END

    # ==============================

    RENDER_MAP_LOOP_X_START:
        addi s4, zero, 0 # s4 = 0 (current index x)

    RENDER_MAP_LOOP_X:
        li t0, 320
        beq s4, t0, RENDER_MAP_LOOP_X_END

        # ==============================

        # Figure out tile map index
        li t0, 120
        sub t1, s0, t0
        blt t1, t0, RENDER_MAP_X_NOT_MAX

        mv t0, t1 # t1 is greater than t0, so we are keeping it

        RENDER_MAP_X_NOT_MAX:
        add t0, t0, s4 # t0 is the position of the tile which must be rendered
        slli t1, t0, 4 # We figure out the actual tile by dividing it by 16
        
        li t2, 16
        rem t0, t0, t2 # We save the mod as well

        # Now figure out Y coordinate
        li t2, 160
        sub t3, s1, t2
        blt t3, t2, RENDER_MAP_Y_NOT_MAX

        mv t2, t3

        RENDER_MAP_Y_NOT_MAX:
        add t2, t2, s4
        slli t3, t2, 4

        li t4, 16
        rem t2, t2, t4

        # The tile is GAMEMAP + X * Y
        la t4, overworld_map
        # mul t5, t3, t1
        # add t4, t4, t5

        lb t4, 8(t4) # The index is t4

        # Get tile map at index
        li t5, 16
        mul t4, t4, t5

        la t5, tilemap_overworld
        add t5, t5, t4

        add t5, t5, t0

        mv a0, t5
        mv a1, s4
        mv a2, s3
        mv a3, zero
        
        li a4, 16
        sub a4, t0, a4

        li a5, 16
        sub a5, t2, a5

        jal ra, PRINT

        # ==============================

        addi s4, s4, 16

        j RENDER_MAP_LOOP_X

    RENDER_MAP_LOOP_X_END:

    # ==============================

    addi s3, s3, 16

    j RENDER_MAP_LOOP_Y
RENDER_MAP_LOOP_Y_END:

END: j END

# ===================== Função PRINT_TILE =====================

# Carrega um tile na tela assumindo 16x16
# Offset precisa ser divisivel por 4
# Assumindo que o player sempre mova de 4n em 4n pixels

# a0 = endereço imagem
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

# ===================== Função PRINT =====================

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