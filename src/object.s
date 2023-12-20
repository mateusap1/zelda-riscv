# ======= Functions =======
# GET_OBJECT_POS
# GET_OBJECT_INFO
# GET_CAMERA_POSITIONS
# MOVE_RIGHT
# MOVE_LEFT
# MOVE_UP
# MOVE_DOWN
# =========================

# ===================== GET_OBJECT_POS =====================
# a0 = tilemap positions (32 bit) - Objects[i][0]

# Retorna
# a0 = Tile Pos X
# a1 = Tile Pos Y
# a2 = Tile Offset X
# a3 = Tile Offset Y

GET_OBJECT_POS:
    li t0, 0xfff00000
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

    mv a0, t0
    mv a1, t1
    mv a2, t2
    mv a3, t3

    jalr zero, ra, 0
# =====================================================

# ===================== GET_OBJECT_INFO =====================
# a0 = player info (32 bit) - Objects[i][3]

# Retorna
# a0 = speed
# a1 = inventory
# a2 = current animation
# a3 = animation index
# a4 = hp

GET_OBJECT_INFO:
    li t0, 0xff000000
    and t0, a0, t0
    srli t0, t0, 24 # t0 = speed

    li t1, 0x0ff0000
    and t1, a0, t1
    srli t1, t1, 16 # t2 = inventory

    li t2, 0x0f000
    and t2, a0, t2
    srli t2, t2, 12 # t2 = current animation

    li t3, 0x0f00
    and t3, a0, t3
    srli t3, t3, 8 # t3 = animation index

    li t4, 0x0ff
    and t4, a0, t4 # t4 = hp

    mv a0, t0
    mv a1, t1
    mv a2, t2
    mv a3, t3
    mv a4, t4

    jalr zero, ra, 0

# =====================================================

# ================ GET_CAMERA_POSITIONS ================
# a0 = registrador
# Retorna (a0=metade da esquerda, a1=metade da direita)

GET_CAMERA_POSITIONS:
    srli t0, a0, 16

    li t2, 65535
    and t1, a0, t2

    mv a0, t0
    mv a1, t1

    jalr zero, ra, 0
# ================================================

# =========== MOVE_RIGHT ===========
# a0 = position
# a1 = speed
# a2 = edge value

# Returns
# a0 = new position
# a1 = whether it got to the edge
MOVE_RIGHT:
    addi sp, sp, -4
    sw ra, 0(sp)

    mv a7, a1 # save speed as a7
    li a6, 0 # This will indicate if we got to the edge

    mv a5, a2

    # We break this position down
    mv a0, a0
    jal ra, GET_OBJECT_POS

MOVE_RIGHT_OFFSET:
    # Adiciona ao offsetX speed % 16
    # Adiciona a0 posX speed / 16

    li t0, 16
    rem t0, a7, t0
    add a2, a2, t0

    li t0, 16
    div t0, a7, t0
    add a0, a0, t0

    bge a0, a5, MOVE_RIGHT_EDGE

    li t0, 16
    blt a2, t0, MOVE_RIGHT_END

MOVE_RIGHT_OFFSET_OVERFLOW:
    # Se offsetX >= 16,
    #   offsetX = offsetX - 16;
    #   posX += 1;

    li t0, 16
    sub a2, a2, t0
    addi a0, a0, 1

    blt a0, a5, MOVE_RIGHT_END

MOVE_RIGHT_EDGE:
    # Se posX >= 19,
    #   offsetX = 0;
    #   posX = 19;

    mv a0, a5
    mv a2, zero
    li a6, 1

MOVE_RIGHT_END:
    or t0, zero, a3
    slli a2, a2, 4
    or t0, t0, a2
    slli a1, a1, 8
    or t0, t0, a1
    slli a0, a0, 20
    or t0, t0, a0

    mv a0, t0
    mv a1, a6

    lw ra, 0(sp)
    addi sp, sp, 4

    jalr zero, ra, 0
# ================

# =========== MOVE_LEFT ===========
# a0 = position
# a1 = speed

# Returns
# a0 = new position
# a1 = whether it got to the edge
MOVE_LEFT:
    addi sp, sp, -4
    sw ra, 0(sp)

    mv a7, a1 # save speed as a7
    li a6, 0 # This will indicate if we got to the edge

    # We break this position down
    mv a0, a0
    jal ra, GET_OBJECT_POS

MOVE_LEFT_OFFSET:
    # Subtrai ao offsetX speed % 16
    # Subtrai a0 posX speed / 16

    li t0, 16
    rem t0, a7, t0
    sub a2, a2, t0

    li t0, 16
    div t0, a7, t0
    sub a0, a0, t0

    blt a0, zero, MOVE_LEFT_EDGE
    bge a2, zero, MOVE_LEFT_END

MOVE_LEFT_OFFSET_OVERFLOW:
    # Se offsetX < 0,
    #   offsetX += 16;
    #   posX -= 1;

    addi a2, a2, 16
    addi a0, a0, -1

    bge a0, zero, MOVE_LEFT_END

MOVE_LEFT_EDGE:
    # Se posX < 0,
    #   offsetX = 0;
    #   posX = 0;

    mv a0, zero
    mv a2, zero
    li a6, 1

MOVE_LEFT_END:
    or t0, zero, a3
    slli a2, a2, 4
    or t0, t0, a2
    slli a1, a1, 8
    or t0, t0, a1
    slli a0, a0, 20
    or t0, t0, a0

    mv a0, t0
    mv a1, a6

    lw ra, 0(sp)
    addi sp, sp, 4

    jalr zero, ra, 0
# ================

# =========== MOVE_DOWN ===========
# a0 = position
# a1 = speed

# Returns
# a0 = new position
# a1 = whether it got to the edge
MOVE_DOWN:
    addi sp, sp, -4
    sw ra, 0(sp)

    mv a7, a1 # save speed as a7
    li a6, 0 # This will indicate if we got to the edge

    # We break this position down
    mv a0, a0
    jal ra, GET_OBJECT_POS

MOVE_DOWN_OFFSET:
    # Adiciona ao offsetY speed % 16
    # Adiciona a0 posY speed / 16

    li t0, 16
    rem t0, a7, t0
    add a3, a3, t0

    li t0, 16
    div t0, a7, t0
    add a1, a1, t0

    li t0, 14
    bge a1, t0, MOVE_DOWN_EDGE

    li t0, 14
    blt a3, t0, MOVE_DOWN_END

MOVE_DOWN_OFFSET_OVERFLOW:
    # Se offsetY >= 16,
    #   offsetY -= 16;
    #   posY += 1;

    li t0, 16
    sub a3, a3, t0
    addi a1, a1, 1

    li t0, 19
    blt a1, t0, MOVE_DOWN_END

MOVE_DOWN_EDGE:
    # Se posY >= 14,
    #   offsetY = 0;
    #   posY = 14;

    li a1, 14
    mv a4, zero
    li a6, 1

MOVE_DOWN_END:
    or t0, zero, a3
    slli a2, a2, 4
    or t0, t0, a2
    slli a1, a1, 8
    or t0, t0, a1
    slli a0, a0, 20
    or t0, t0, a0

    mv a0, t0
    mv a1, a6

    lw ra, 0(sp)
    addi sp, sp, 4

    jalr zero, ra, 0
# ================

# =========== MOVE_UP ===========
# a0 = position
# a1 = speed

# Returns
# a0 = new position
# a1 = whether it got to the edge
MOVE_UP:
    addi sp, sp, -4
    sw ra, 0(sp)

    mv a7, a1 # save speed as a7
    li a6, 0 # This will indicate if we got to the edge

    # We break this position down
    mv a0, a0
    jal ra, GET_OBJECT_POS

MOVE_UP_OFFSET:
    # Subtrai ao offsetY speed % 16
    # Subtrai a0 posY speed / 16

    li t0, 16
    rem t0, a7, t0
    sub a3, a3, t0

    li t0, 16
    div t0, a7, t0
    sub a1, a1, t0

    blt a1, zero, MOVE_UP_EDGE
    bge a3, zero, MOVE_UP_END

MOVE_UP_OFFSET_OVERFLOW:
    # Se offsetY < 0,
    #   offsey += 16;
    #   posy -= 1;

    addi a3, a3, 16
    addi a1, a1, -1

    bge a1, zero, MOVE_UP_END

MOVE_UP_EDGE:
    # Se posX < 0,
    #   offsetX = 0;
    #   posX = 0;

    mv a1, zero
    mv a3, zero
    li a6, 1

MOVE_UP_END:
    or t0, zero, a3
    slli a2, a2, 4
    or t0, t0, a2
    slli a1, a1, 8
    or t0, t0, a1
    slli a0, a0, 20
    or t0, t0, a0

    mv a0, t0
    mv a1, a6

    lw ra, 0(sp)
    addi sp, sp, 4

    jalr zero, ra, 0

# ====================