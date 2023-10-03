.text
SETUP:
    # Tamanho da tela 320 x 240

    la a0, tile
    li a1, 0
    li a2, 0
    li a3, 0

    jal ra, PRINT

LOOP: j LOOP

# ===================== Função LOAD_SCREEN =====================

# ===================== Função PRINT =====================

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

# ========================================================

.data
.include "sprites/tile.s"
.include "sprites/map.s"
.include "sprites/char.s"