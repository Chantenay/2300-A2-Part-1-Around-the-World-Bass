.syntax unified
.global main

.type main, %function
main:
  @ initialisation
  bl init
  bl BSP_AUDIO_Buffer

  mov r4, 0 @counter 

  b initialisation


@initialises the array counter
initialisation: 
  @memory address of song array 
  ldr r0, =around_the_world_bass 
  @length of array: 
  ldr r1, [r0]
  @array counter
  mov r2, 0
  @offset 
  mov r3, 4

  push {r0, r1, r2, r3} 

  b song_loop

@restarts the song if counter is reached
@otherwise goes to the next array member
song_loop:
  pop {r0, r1, r2, r3} 

  adds r2, 1

  cmp r2, r1
  beq initialisation

  push {r0, r1, r2, r3} 

  b calculations

@calculations for the wave 
calculations: 
  @load in current data 
  pop {r0, r1, r2, r3} 

  ldr r6, [r0, r3] @frequency from data
  adds r3, 4 @add to counter
  ldr r5,  [r0, r3] @time note to be player
  adds r3, 4 @add to counter

  @update data 
  push {r0, r1, r2, r3} 

  @check if frequency is 0 (silence)
  cmp r6, 0
  mov r0, 1
  @if it is go to the blank loop
  beq blank_loop

  @based on code from ass1 used to calculate triangle wave sequence
  ldr r10, =48000 
  udiv r7, r10, r6 @number of outputs needed for frequency per period
  mov r9, 2
  udiv r7, r7, r9 @number of outputs needed for frequency per half period
  ldr r8, =0x14000 @range of numbers from peak to trough 
  udiv r8, r8, r7 @number to increase/decrease by

  b subloop

@based on code from ass 1
@subtracts from sequence counter until reaches trough 
subloop:
  @add to output counter
  add r1, 1
  @move value to be played into r0
  mov r0, r4
  push {r1}
  @ bl to BSP_AUDIO_OUT_Play_Sample with that value in r0
  bl BSP_AUDIO_OUT_Play_Sample
  pop {r1}

  @calculate the next value in the triangle signal
  subs r4, r8

  @check if note has played for desired length 
  cmp r1, r5
  beq song_loop

  @check if value counter (r4) has reached the min amplitude
  cmp r4, -0x7000
  ble addloop

  b subloop

@based on code from ass 1
@adds to sequence counter until reaches peak 
addloop:
  @add to output counter
  add r1, 1
  @move value to be played into r0
  mov r0, r4
  push {r1}

  @ bl to BSP_AUDIO_OUT_Play_Sample with that value in r0
  bl BSP_AUDIO_OUT_Play_Sample

  pop {r1}

  @ calculate the next value in the triangle signal
  adds r4, r8

  @check if note has played for desired length 
  cmp r1, r5
  beq song_loop

  @compare counter to max value
  cmp r4, 0x7000
  bge subloop

  b addloop

@used for silence 
blank_loop:
  mov r0, 0
  @reset the counter
  mov r4, 0
  @ bl to BSP_AUDIO_OUT_Play_Sample with that value in r0
  push {r1} 
  bl BSP_AUDIO_OUT_Play_Sample
  pop {r1}
  @add to length counter
  add r1, 1

  @check if note has played for desired length 
  cmp r1, r5
  beq song_loop
  b blank_loop

.data
@song array - stored in frequency, (time * 48000) pairs 
around_the_world_bass:
  .word 38 @ Length of array: 38

  .word 110, 12000
  .word 0, 12000
  .word 110, 12000
  .word 0, 12000
  .word 110, 12000
  .word 0, 12000
  .word 110, 12000
  .word 0, 12000
  .word 131, 12000
  .word 0, 12000
  .word 131, 12000
  .word 0, 12000
  .word 131, 12000
  .word 0, 12000
  .word 131, 12000
  .word 147, 12000
  .word 165, 12000
  .word 0, 12000
  .word 165, 12000
  .word 0, 12000
  .word 165, 12000
  .word 0, 12000
  .word 165, 12000
  .word 0, 12000
  .word 185, 6000
  .word 0, 6000
  .word 165, 6000
  .word 0, 6000
  .word 147, 6000
  .word 0, 6000
  .word 131, 6000
  .word 0, 6000  
  .word 123, 6000
  .word 0, 6000
  .word 110, 6000
  .word 0, 6000
  .word 98, 12000
  .word 110, 12000