.data

# Gamemaps
.include "data/maps/gamemap/overworld_gamemap.s"
.include "data/maps/gamemap/underworld_gamemap.s"
.include "data/maps/gamemap/areasecreta_gamemap.s"
.include "data/maps/gamemap/masmorra_gamemap.s"
.include "data/maps/gamemap/telainicial_gamemap.s"

# Tilemaps
.include "data/maps/tilemap/overworld_tilemap.s"
.include "data/maps/tilemap/masmorra_tilemap.s"
.include "data/maps/tilemap/areasecreta_tilemap.s"
.include "data/maps/tilemap/telainicial_tilemap.s"

# Collisionmaps
.include "data/maps/collisionmap/overworld_collision.s"
.include "data/maps/collisionmap/areasecreta_collision.s"
.include "data/maps/collisionmap/masmorra_collision.s"
.include "data/maps/collisionmap/underworld_collision.s"

# Map
.include "data/maps.s"

# Sprites
.include "sprites/player.s"
.include "sprites/enemy.s"

# Animations
.include "data/animations/player_animation.s"
.include "data/animations/enemy_animation.s"

# Objects
.include "data/objects.s"

# Sounds
.include "midi/startmidi.s"

CAMERA_POSITION: .word 0
CURRENT_MAP: .byte 0
CURRENT_FRAME: .word 0

.text


SETUP:
    # ==========================
    # s0 = Camera position em termos de (X/320)x(Y/240)
    # s1 = Current map index
    # s2 = Current frame
    # ==========================

    li s0, 0x00000000
    li s1, 0
    li s2, 0

    jal ra, START_MAP

    RESET_MUSIC: 
    la t4,startmidi  #endereco da musica
    lw t3,0(t4)     # t3 = quantidade de notas 
    addi t4,t4,4     #t4 = endereco da primeira nota 
    mv t5,zero  #contador de notas
    li a2,68		# define o instrumento
    li a3,127		# define o volume

LOOP_START_SCREEN:
    #################   TELA INICIAL    ###########

    beq t5,t3,RESET_MUSIC		#verifica se a musica acabou e reinicia
	lw a0,0(t4)		# le o valor da nota
	lw a1,4(t4)		# le a duracao da nota
	li a7,31		# define a chamada de syscall
	ecall			# toca a nota
    li a7,32        
    mv a0,a1
    ecall           #pausa de a1 ms 
	addi t5,t5,1	# incrementa o contador de notas
	addi t4,t4,8    #incrementa nota


    li t0, 0xFF200000 # t0 = endereço de controle do teclado
	lw t1, 0(t0) # t1 = conteudo de t0
	andi t2, t1, 1 # Mascara o primeiro bit (verifica sem tem tecla)
	beqz t2, LOOP_START_SCREEN # Se tem tecla continua o jogo

    jal ra, START_MAP

GAME_LOOP:
    la t0, CAMERA_POSITION
    lw s0, 0(t0)

    # Alterante frames
    # Do it on 0 while we are at 1,
    # Then do it at 1 while we are at 0

    xori s2, s2, 1

    # Loop over objects 
    mv a0, s1
    mv a1, s0
    mv a2, s2
    jal ra, RUN_OBJECTS

    li t0, 0xFF200604
    sb s2, 0(t0)

    la t0, CURRENT_FRAME
    lw t1, 0(t0)
    addi t1, t1, 1
    sw t1, 0(t0)

    j GAME_LOOP

GAME_END: j GAME_END

# ========= START_MAP =========
START_MAP:
    addi sp, sp, -4
    sw ra, 0(sp)

    la t0, CAMERA_POSITION
    lw s0, 0(t0)

    la t0, CURRENT_MAP
    lb s1, 0(t0)

    mv a0, s0
    jal ra, GET_CAMERA_POSITIONS

    mv a2, a0
    mv a3, a1
    mv a0, s1
    li a1, 0

    jal ra, RENDER_MAP

    mv a0, s0
    jal ra, GET_CAMERA_POSITIONS

    mv a2, a0
    mv a3, a1
    mv a0, s1
    li a1, 1

    jal ra, RENDER_MAP

    lw ra, 0(sp)
    addi sp, sp, 4

    jalr zero, ra, 0

# =============================

# ================ RUN_OBJECTS ================

# a0 = current map index
# a1 = camera position
# a2 = current frame

# s0 = objects index
# s1 = current map index
# s2 = total objects num
# s3 = camera position
# s4 = current frame
# s5 = endereço tilemap
# s6 = endereço gamemap
# s7 = Objects[i][0]
# s8 = Objects[i][1]
# s9 = Objects[i][2]
# s10 = Objects[i][3]

RUN_OBJECTS:
    addi sp, sp, -48
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

    mv s0, zero
    mv s1, a0 # current map index

    la t0, objects 
    lw s2, 0(t0) # total objects number

    mv s3, a1
    mv s4, a2

    # ========== Find out current tilemap and gamemap ==========
    la t0, maps # t0 = maps address
    addi t0, t0, 4 # skip maps num
    slli t1, s1, 3 # multiply index by 8
    add t0, t0, t1 # maps address + 4 + map_index * 8

    lw s5, 0(t0)
    lw s6, 4(t0)
    # ==========================================================

RUN_OBJECTS_LOOP:
    beq s0, s2, RUN_OBJECTS_END

    # ============= Load object data =============

        # ========== Figure object address ==========
        la t0, objects
        addi t0, t0, 4
        slli t1, s0, 4
        add t0, t0, t1
        # ===========================================

    lw s7, 0(t0)
    lw s8, 4(t0)
    lw s9, 8(t0)
    lw s10, 12(t0)
    # ============================================

    # If camera cannot see it, make it disappear
    # ===========================================
    mv a0, s7
    jal ra, GET_OBJECT_POS

    mv a6, a0
    mv a7, a1

    la t0, CAMERA_POSITION
    lw t0, 0(t0)

    mv a0, t0
    jal ra, GET_CAMERA_POSITIONS

    slli a6, a6, 4
    slli a7, a7, 4

    blt a6, a0, RUN_OBJECTS_LOOP_DESTROY_OBJECT
    blt a7, a1, RUN_OBJECTS_LOOP_DESTROY_OBJECT

    addi a0, a0, 320
    addi a1, a1, 240

    bgt a6, a0, RUN_OBJECTS_LOOP_DESTROY_OBJECT
    bgt a7, a1, RUN_OBJECTS_LOOP_DESTROY_OBJECT

    j RUN_OBJECTS_LOOP_SKIP_DESTROY_OBJECT

RUN_OBJECTS_LOOP_DESTROY_OBJECT:
    mv a0, s10
    jal ra, GET_OBJECT_INFO

    li t0, 15
    slli a0, a0, 24
    slli a1, a1, 16
    slli a2, t0, 12
    slli a3, a3, 8

    or t0, zero, a0
    or t0, t0, a1
    or t0, t0, a2
    or t0, t0, a3
    or t0, t0, a4

    # ========== Figure object address ==========
    la t2, objects
    addi t2, t2, 4
    slli t1, s0, 4
    add t2, t2, t1
    # ===========================================

    sw t0, 12(t2)

    j RUN_OBJECTS_LOOP_SKIP

RUN_OBJECTS_LOOP_SKIP_DESTROY_OBJECT:
    # ============= Load object data =============

        # ========== Figure object address ==========
        la t0, objects
        addi t0, t0, 4
        slli t1, s0, 4
        add t0, t0, t1
        # ===========================================

    lw s7, 0(t0)
    lw s8, 4(t0)
    lw s9, 8(t0)
    lw s10, 12(t0)
    # ============================================

    # ===========================================

    # Animation 15 means object is not present
    mv a0, s10
    jal ra, GET_OBJECT_INFO

    # If is not present we only run its code

    li t0, 15
    beq a2, t0, RUN_OBJECTS_LOOP_RUN_CODE

    # =========== Render tiles ===========
    # Pra a gente não apagar o mapa no caminho desse
    # objeto

    mv a0, s5 # a0 = tilemap address
    mv a1, s6 # a1 = gamemap address
    mv a2, s4 # a2 = frame
    mv a3, s7 # a3 = tile position
    mv a4, s3 # a4 = camera position
    jal ra, RENDER_BACKGROUND_TILES
    # ====================================
    

    # ====== Print current sprite ======
    mv a0, s7 # a0 = object position - Objects[i][0]
    mv a1, s8 # a1 = object animation address - Objects[i][1]
    mv a2, s10 # a2 = object info - Objects[1][2]
    mv a3, s3 # a3 = camera position
    mv a4, s4 # a4 = frame
    jal ra, RENDER_OBJECT
    # ======================================

RUN_OBJECTS_LOOP_RUN_CODE:

    # ========== Figure object address ==========
    la t0, objects
    addi t0, t0, 4
    slli t1, s0, 4
    add t0, t0, t1
    # ===========================================

    # =========== Execute user code ===========
    mv a0, s7
    mv a1, s8
    mv a2, s10
    mv a3, t0
    jalr ra, s9, 0
    # =========================================

    # ========== Figure object address ==========
    la t0, objects
    addi t0, t0, 4
    slli t1, s0, 4
    add t0, t0, t1
    # ===========================================

    lw t0, 12(t0)

    # Skip if object is destroyed

    # Animation 15 means object is not present
    mv a0, t0
    jal ra, GET_OBJECT_INFO

    li t0, 15
    beq a2, t0, RUN_OBJECTS_LOOP_SKIP

    # Atualizar camera
    la t0, CAMERA_POSITION
    lw s3, 0(t0)

    # Atualizar mapa
    la t0, CURRENT_MAP
    lb s1, 0(t0)

    # ========== Find out current tilemap and gamemap ==========
    la t0, maps # t0 = maps address
    addi t0, t0, 4 # skip maps num
    slli t1, s1, 3 # multiply index by 8
    add t0, t0, t1 # maps address + 4 + map_index * 8

    lw s5, 0(t0)
    lw s6, 4(t0)
    # ==========================================================

    # =========== Render tiles ===========
    # Pra a gente não apagar o mapa no caminho desse
    # objeto

    mv a0, s5 # a0 = tilemap address
    mv a1, s6 # a1 = gamemap address
    mv a2, s4 # a2 = frame
    mv a3, s7 # a3 = tile position
    mv a4, s3 # a4 = camera position
    jal ra, RENDER_BACKGROUND_TILES
    # ====================================

    # ============= Load object data =============

        # ========== Figure object address ==========
        la t0, objects
        addi t0, t0, 4
        slli t1, s0, 4
        add t0, t0, t1
        # ===========================================

    lw t1, 0(t0)
    lw t2, 4(t0)
    lw t3, 12(t0)
    # ============================================

    # ====== Print current sprite ======
    mv a0, t1 # a0 = object position - Objects[i][0]
    mv a1, t2 # a1 = object animation address - Objects[i][1]
    mv a2, t3 # a2 = object info - Objects[1][2]
    mv a3, s3 # a3 = camera position
    mv a4, s4 # a4 = frame
    jal ra, RENDER_OBJECT
    # ======================================

    li t0, 0xFF200604
    sb s4, 0(t0)
    xori t1, s4, 1

    # =========== Render tiles ===========
    # Pra a gente não apagar o mapa no caminho desse
    # objeto

    mv a0, s5 # a0 = tilemap address
    mv a1, s6 # a1 = gamemap address
    mv a2, t1 # a2 = frame
    mv a3, s7 # a3 = tile position
    mv a4, s3 # a4 = camera position
    jal ra, RENDER_BACKGROUND_TILES
    # ====================================

    # ============= Load object data =============

        # ========== Figure object address ==========
        la t0, objects
        addi t0, t0, 4
        slli t1, s0, 4
        add t0, t0, t1
        # ===========================================

    lw s7, 0(t0)
    lw s8, 4(t0)
    lw s9, 8(t0)
    lw s10, 12(t0)
    # ============================================

    xori t0, s4, 1

    # ====== Print current sprite ======
    mv a0, s7 # a0 = object position - Objects[i][0]
    mv a1, s8 # a1 = object animation address - Objects[i][1]
    mv a2, s10 # a2 = object info - Objects[1][2]
    mv a3, s3 # a3 = camera position
    mv a4, t0 # a4 = frame
    jal ra, RENDER_OBJECT
    # ======================================

    xori t1, s4, 1
    li t0, 0xFF200604
    sb t1, 0(t0)

RUN_OBJECTS_LOOP_SKIP:
    addi s0, s0, 1

    j RUN_OBJECTS_LOOP

RUN_OBJECTS_END:
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

    addi sp, sp, 48
    jalr zero, ra, 0

# =============================================

.include "src/object.s"
.include "src/render.s"

# Objects Update
.include "data/objects/player_update.s"
.include "data/objects/enemy_update.s"
