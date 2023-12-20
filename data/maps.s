maps:
    .word 4 # Number of maps
    .word overworld_tilemap, overworld_gamemap, areasecreta_tilemap, areasecreta_gamemap, masmorra_tilemap, masmorra_gamemap, telainicial_tilemap, telainicial_gamemap

collision:
    .word 4
    .word overworld_collision, areasecreta_collision, masmorra_collision, underworld_collision