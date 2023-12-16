# Zelda RISC-V

# Arquitetura

## Tilemap
Teremos apenas um tilemap geral que irá ter todos os tiles possíveis. Eles
poderão ser indexados através da sua posição. (acho que eu vou mudar de ideia)

## Gamemap
O gamemap é o dado responsável por representar um mapa. É uma array de bytes.

O byte pode representar o index do tilemap ou, pode declarar uma função especial ao byte anterior.  O bit mais signifativo é o que determina se esse byte é simplesmente um index ou uma declaração de função.

Exemplo:
* 1000_0000 não é um index do tilemap, já que o bit mais significativo é 1.
* 0000_0011 indica o index do tilemap 3, já que o bit mais significativo é 0.

```
overworld_map: .word 20, 15
.byte 0000_0000, 0000_0101, 1000_0001, 0000_0001, etc
```

`overworld_map: .word 20, 15` nos diz que o nosso mapa tem um tamanho de 20x15 tiles (de 16x16 pixeis cada).
`.byte 0000_0000, 0000_0101` nos diz que o primeiro tile é o tile do index 0 e o segundo de index 5 (101).
`, 1000_0001` nos diz que o último tile, aquele de index 5 visto anteriormente, tem a função especial 001.
`, 0000_0001` nos diz que o terceiro tile é o tile de index 1.

Vejamos agora as funções especiais. Lembrando que todas começam com o bit 1 e determinam a função do tile determinado pelo byte anterior.

00. 0000 -> Tile com colisão
01. 0001 -> Local de spawn do player
02. 0010 -> Spawn do inimigo 1
03. 0011 -> Spawn do inimigo 2
04. 0100 -> Spawn do inimigo 3
05. 0101 -> Spawn do inimigo 4
06. 0110 -> Portal próxima fase
07. 0111 -> Portal fase anterior
08. 1000 -> Portal próxima fase
09. 1001 -> Item 1
10. 1010 -> Item 2
11. 1011 -> Item 3
12. 1100 -> Item 4

# Renderização
A posição atual do player ficará salva nos registradores s0 e s1.

## Helpers
As a helper for debugging purposes, you can add the following code:

```assembly
# ========================= DEBUG =========================

DEBUG_CONDITIONAL:
    li t2, 2
    bne s1, t2, DEBUG_END

DEBUG_START:
    li a7, 1
    mv a0, a1
    ecall

    # li a7, 1
    # mv a0, t1
    # ecall

    li a7, 10    # "exit" ecall
    li a0, 0     # exit with code 0 
    ecall

DEBUG_END:

# =========================================================
```

You can replace DEBUG_CONDITIONAL with the conditional you want.

For testing the print function, use this:

```assembly
# =============== TEST_PRINT ===============

# a0 = endereço imagem
# a1 = x
# a2 = y
# a3 = frame (0 ou 1)
# a4 = largura x
# a5 = largura y

la t0, tilemap_overworld
addi t0, t0, 8

mv a0, t0
mv a1, zero
mv a2, zero
mv a3, zero
li a4, 16
li a5, 16

jal ra, PRINT

# ==========================================
```

Para testar o print_tile

```assembly
la a0, tilemap_overworld
li a1, 16
li a2, 0
mv a3, zero
li a4, 2
li a5, 8
li a6, 8

jal ra, PRINT_TILE
```

Para debugar o render

```assembly
# ============ DEBUG ============
li a0, 'x'
li a7, 11
ecall

mv a0, t3
li a7, 1
ecall

li a0, 'y'
li a7, 11
ecall

mv a0, t1
li a7, 1
ecall

li a0, 'i'
li a7, 11
ecall

mv a0, s4
li a7, 1
ecall

li a0, 'j'
li a7, 11
ecall

mv a0, s3
li a7, 1
ecall

li a0, 'n'
li a7, 11
ecall

mv a0, t5
li a7, 1
ecall

li a0, '\n'
li a7, 11
ecall
# ===============================
```