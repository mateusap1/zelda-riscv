# ======= Functions =======
# GET_OBJECT_POS
# GET_OBJECT_INFO
# GET_CAMERA_POSITIONS
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

    li t2, 0x0f00
    and t2, a0, t2
    srli t2, t2, 8 # t2 = current animation

    li t3, 0x0f0
    and t3, a0, t3
    srli t3, t3, 4 # t3 = animation index

    li t4, 0x0f
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