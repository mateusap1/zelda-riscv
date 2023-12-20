objects:
    .word 2
    .word 0x00200200, player_animation, PLAYER_UPDATE, 0x10000034, 0x00600600, enemy_animation, ENEMY_UPDATE, 0x1000F034

# , 0x00600600, enemy_animation, ENEMY_UPDATE, 0x10000034
# PLAYER

# [0]:

# TilePosX: 1 - 0000,0000,0001
# TilePosY: 1 - 0000,0000,0001
# OffsetX: 0 - 0000
# OffsetY: 0 - 0000

# 0000,0000,0001,0000,0000,0001,0000,0000
# 00000000000100000000000100000000

# [1]: player_animation

# [2]: PLAYER_UPDATE

# [3]:

# Speed: 4 - 0000,0100
# Inventory: 0 - 0000,0000 - for the enemy this will determine the movement
# Current Animation: 0 - 0000
# Animation Index: 0 - 0000
# HP: 100 - 0011,0100

# 0000,1000,0000,0000,0000,0000,0011,0100
# 00000100000000000000000000110100