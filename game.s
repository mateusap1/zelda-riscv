.text
SETUP:
    # Tamanho da tela 320 x 240

    la a0, overworld_map
    la a1, tilemap_overworld
    li a2, 0

    jal ra, LOAD_MAP

LOOP: j LOOP

# ==================== Função LOAD_MAP ====================

# a0 = endereço map
# a1 = endereço tilemap
# a2 = frame (0 ou 1)

# t0 = número tile selecionado
# t1 = endereço tilemap atual

# s0 = posição x
# s1 = posição y

LOAD_MAP:
    # Load stack
    addi sp, sp, -8

    sw s0, 4(s0)
    sw s1, 0(s1)

    mv s0, zero # s0 = posx = 0
    mv s1, zero # s1 = posy = 0

LOAD_MAP_LOOP:
    # Setup
    lbu t0, 4(a0) # t0 = tile selecionado (e.g. 0, 1, 2)

    mv t1, a1 # t1 = a1 (endereço tilemap)

    # Add component y
    li t2, 10
    remu t3, t0, t2 # t3 = t0 % 10

    li t2, 320
    mul t3, t3, t2  # t3 = t3 * 320

    add t1, t1, t3 # t1 = t1+t3 = (a1 + (t0 % 10) * 320)

    # Add component x
    li t2, 10
    divu t3, t0, t2 # t3 = floor(t0 / 10)
    slli t3, t3, 16 # t3 = t3 * 16

    add t1, t1, t3 # t1 = t1+t3 = (t1 + (floor(t0 / 10) * 16))

    # Load stack
    addi sp, sp, -16

    sw ra, 12(sp)

    sw a0, 8(a0)
    sw a1, 4(a1)
    sw a2, 0(a2)

    mv a0, t1
    li a7, 1
    ecall

    # Print tile at current position
    mv a0, t1
    mv a1, s0
    mv a2, s1
    mv a3, a2

    jal ra, PRINT

    # Unload stack
    addi sp, sp, 16

    lw ra, 12(sp)

    lw a0, 8(a0)
    lw a1, 4(a1)
    lw a2, 0(a2)

    addi a0, a0, 1

    addi s0, s0, 16

    li t2, 320
    blt s0, t2, LOAD_MAP_LOOP
    
LOAD_MAP_NEXT_LINE:
    mv s0, zero
    addi s1, s1, 16

    li t2, 240
    blt s1, t2, LOAD_MAP_LOOP

LOAD_MAP_FIM:
    # Unload stack
    addi sp, sp, 8

    lw s0, 4(s0)
    lw s1, 0(s1)

    jalr zero, ra, 0

# =========================================================

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

# ========================================================

.data
.include "assets/overworld_map.s"
.include "assets/tilemap_overworld.s"