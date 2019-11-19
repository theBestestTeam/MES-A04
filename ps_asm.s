@  Programmer          : Paul Smith & Amy Dayasundara
@  Course code         : SENG2010
@  Date of Submission  : 2019-11-14
@  Description         : This file contains the assembly code for the psad tilt
@                        game function


    .code   16              @ This directive selects the instruction set being generated.
                            @ The value 16 selects Thumb, with the value 32 selecting ARM.

    .text                   @ Tell the assembler that the upcoming section is to be considered
                            @ assembly language instructions - Code section (text -> ROM)


  @ Function Declaration : int tilt (int hold, char target, char timer)
  @ Description:
  @
  @ Input:                 r0, r1, r2 (r0 holds hold, r1 holds target, r2 holds timer)
  @ Returns:               none

  @@ Function Header Block
      .align  2               @ Code alignment - 2^n alignment (n=2)
                              @ This causes the assembler to use 4 byte alignment

      .syntax unified         @ Sets the instruction set to the new unified ARM + THUMB
                              @ instructions. The default is divided (separate instruction sets)

      .global tilt            @ Make the symbol name for the function visible to the linker

      .code   16              @ 16bit THUMB code (BOTH .code and .thumb_func are required)
      .thumb_func             @ Specifies that the following symbol is the name of a THUMB
                              @ encoded function. Necessary for interlinking between ARM and THUMB code.

  tilt:

    push {lr}                 @ lr value pushed to stack to account for function call

    ldr r3, =hold             @ location of hold global variable stored in r3
    str r0, [r3]              @ hold value stored into global variable

    ldr r3, =target           @ location of target global variable stored in r3
    str r1, [r3]              @ target value stored into global variable

    mov r1, #10               @ value of 10 stored in r1
    mul r0, r2, r1            @ timer variable multiplied for more accurate reading
    ldr r3, =timer            @ location of timer global variable stored in r3
    str r0, [r3]              @ timer value stored into global variable

    ldr  r3, =timeInc         @ location of timeInc global variable stored in r3
    mov r0, #0                @ value decreased to 0
    str  r0, [r3]             @ value set to 0 to reset variable

    ldr  r3, =lastOn          @ location of lastOn global variable stored in r3
    mov r0, #8                @ value set to 8 to put above light range
    str  r0, [r3]             @ value stored in variable to reset for new game

    ldr  r3, =winTick         @ location of winTick global variable stored in r3
    mov r0, #0                @ value set to 0 to reset
    str  r0, [r3]             @ value stored in variable for start of new game

    ldr r3, =myTickCount      @ location of myTickCount global variable stored in r3
    mov r0, #0                @ value set to 0 to reset
    str  r0, [r3]             @ value stored in variable for start of new game

    ldr r1, =LEDaddress       @ Load the GPIO address we need
    ldr r1, [r1]              @ Dereference r1 to get the value we want
    ldrh r0, [r1]             @ Get the current state of that GPIO (half word only)
    and r0, r0, #0x0          @ bitwise and performed to turn appropriate bits off
    strh r0, [r1]             @ Write the half word back to the memory address for the GPIO

    ldr  r3, =gameOn          @ location of gameOn global variable stored in r3
    mov r0, #1                @ value of 1 moved into register 0
    str  r0, [r3]             @ value set to 1 to active game mode

    pop {lr}                  @ link register restored to value from start of function
    bx lr                     @ Return (Branch eXchange) to the address in the link register (lr)

    @@@@@@@
      @ Function Declaration : void lightWheel ()
      @ Description:
      @
      @ Input:                 r0, r1, r2 (r0 holds timer, r1 holds range, r2 holds target)
      @ Returns:               none

      @@ Function Header Block
          .align  2               @ Code alignment - 2^n alignment (n=2)
                                  @ This causes the assembler to use 4 byte alignment

          .syntax unified         @ Sets the instruction set to the new unified ARM + THUMB
                                  @ instructions. The default is divided (separate instruction sets)

          .global lightWheel            @ Make the symbol name for the function visible to the linker

          .code   16              @ 16bit THUMB code (BOTH .code and .thumb_func are required)
          .thumb_func             @ Specifies that the following symbol is the name of a THUMB
                                  @ encoded function. Necessary for interlinking between ARM and THUMB

  lightWheel:
    push {lr}             @ lr value pushed to stack to account for function call


    ldr r3, =xValue       @ Load the most recent variable of the x value
    ldr r1, [r3]          @ Dereference r3 to get the value we want

    ldr r3, =yValue       @ Load the most recent variable of the y value
    ldr r2, [r3]          @ Dereference r3 to get the value we want

    cmp r1, #0            @ x value compared to 0
    beq equalToZero       @ if x is equal to zero, moves to middle block
    blt lessThanZero      @ if less than zero, moves to last block


    mov r5, #0             @LED0 value stored in r5
    cmp r2, #0
    beq correct            @if y==0 then LED0 should be on
    mov r5, #1             @ LED1 value stored in r5
    cmp r2, #0
    bgt correct            @ if y>0 then LED01 should be on
    mov r5, #2             @ LED2 value stored in r5
    cmp r2, #0
    blt correct            @ if y<0 then LED02 should be on

    equalToZero:           @ jumps to here should z be equal to zero
    cmp r1, #0
    blt lessThanZero       @ if less than zero, moves to the next check

    mov r5, #3
    cmp r2, #0
    bgt correct            @ if y>0 then LED03 should be on
    mov r5, #4
    cmp r2, #0
    blt correct            @ if y<0 then LED04 should be on

    lessThanZero:          @ if x is neither greater nor less than zero it must be zero

    mov r5, #5
    cmp r2, #0
    bgt correct            @ if y>0 then LED05 should be on
    mov r5, #6
    cmp r2, #0
    blt correct            @ if y<0 then LED06 should be on

    mov r5, #7             @ if no other lights are on then LED 07 should be on

    correct:               @ match is found and light is turned on

    ldr r3, =lastOn        @ Load the last light value to be turned on
    ldr r0, [r3]           @ load value into regiser 0
    cmp r0, #7             @ compare against top of light range
    bgt skipLight          @ skip if contents are above light range
    ldr r0, [r3]           @ De-reference r3 to get the value we want
    bl BSP_LED_Toggle
    skipLight:             @ exits here if skip condition met

    mov r0, r5             @ active light stored in r0
    ldr  r1, =lastOn       @ lastOn global variable loaded
    str  r0, [r1]          @ store most recent light value into lastOn
    bl BSP_LED_Toggle      @ current target value used to activate correct light

    ldr r3, =target        @ Load the last light value to be turned on
    ldr r1, [r3]           @ load value into regiser 0
    mov r0, r5             @ active light stored in r0
    cmp r0, r1             @ compare against register containing current active light
    bgt noWin              @ if greater than the value, then no win condition is met
    blt noWin              @ if less than the value, then no win condition is met

    ldr  r1, =winTick      @ Address of winTick global variable stored in r1
    ldr  r0, [r1]          @ Load r0 with the address pointed at by r1 (winTick address)
    add  r0, r0, #100      @ Increment r0 by 100 (for ms)
    str  r0, [r1]          @ Store the current r0 value back to the address pointed at by r1
    b closer               @ jumps past noWin block to avoid resetting of winTick value

    noWin:                 @ if incorrect light is on the winTick value is reset
    ldr  r1, =winTick      @ Address of winTick global variable stored in r1
    ldr  r0, [r1]          @ Load r0 with the address pointed at by r1 (winTick address)
    mov  r0, #0            @ Increment r0 by 100 (for ms)
    str  r0, [r1]          @ Store the current r0 value back to the address pointed at by r1

    closer:
    pop {lr}
    bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @ Function Declaration : void readAccel ()
  @ Description:           reads the acceleromters and stores values in global variables
  @
  @ Input:                 none
  @ Returns:               none

  @@ Function Header Block
      .align  2               @ Code alignment - 2^n alignment (n=2)
                              @ This causes the assembler to use 4 byte alignment

      .syntax unified         @ Sets the instruction set to the new unified ARM + THUMB
                              @ instructions. The default is divided (separate instruction sets)

      .global readAccel       @ Make the symbol name for the function visible to the linker

      .code   16              @ 16bit THUMB code (BOTH .code and .thumb_func are required)
      .thumb_func             @ Specifies that the following symbol is the name of a THUMB
                              @ encoded function. Necessary for interlinking between ARM and THUMB code.

  readAccel:

    push {lr}                 @ lr value pushed to stack to account for function call

    mov r0, #0x32             @ device address location stored in register 0
    mov r1, #0x29             @ high X register address stored in register 1
    bl COMPASSACCELERO_IO_Read @ function called to read accelerometer data
    sxtb r0,r0                @ extend the signed 8 bit value in r0 to be a signed 32 bit value
    asr r0, r0, #5            @ shift right by 5, (equivalent of dividing by 64)
    ldr  r1, =xValue          @ Address of xValue stored in r1
    str  r0, [r1]             @ store value of X register into address pointed to by xValue

    mov r0, #0x32             @ device address location stored in register 0
    mov r1, #0x2B             @ high X register address stored in register 1
    bl COMPASSACCELERO_IO_Read @ function called to read accelerometer data
    sxtb r0,r0                @ extend the signed 8 bit value in r0 to be a signed 32 bit value
    asr r0, r0, #5            @ shift right by 5, (equivalent of dividing by 64)
    ldr  r1, =yValue          @ Address of yValue stored in r1
    str  r0, [r1]             @ store value of Y register into address pointed to by yValue

    bl gameTimer              @ gameTimer function called to manage game time values

    pop {lr}
    bx lr


    @@@@@@@
      @ Function Declaration : int gameTimer()
      @ Description:           function for the managing of the game timer for
      @                        loss condition
      @
      @ Input:                 none
      @ Returns:               none

      @@ Function Header Block
          .align  2               @ Code alignment - 2^n alignment (n=2)
                                  @ This causes the assembler to use 4 byte alignment

          .syntax unified         @ Sets the instruction set to the new unified ARM + THUMB
                                  @ instructions. The default is divided (separate instruction sets)

          .global gameTimer            @ Make the symbol name for the function visible to the linker

          .code   16              @ 16bit THUMB code (BOTH .code and .thumb_func are required)
          .thumb_func             @ Specifies that the following symbol is the name of a THUMB
                                  @ encoded function. Necessary for interlinking between ARM and THUMB code.
        @ This code is untested – test it out – can you make it work?
    gameTimer:
      push {lr}

      ldr  r1, =winTick       @ Address of winTick global variable stored in r1
      ldr  r0, [r1]           @ Load r0 with the address pointed at by r1 (winTick address)
      ldr  r2, =hold          @ Address of hold global variable stored in r1
      ldr  r1, [r2]           @ Load r0 with the address pointed at by r1 (hold address)
      cmp r0, r1              @ winTick value compared against hold value
      blt notYet              @ if winTick less than hold then game continues
      bl gameWin              @ if winTick is equal to or greater than hold, then win condition triggered

      notYet:
      ldr  r1, =timeInc       @ Address of timeInc global variable stored in r1
      ldr  r0, [r1]           @ Load r0 with the address pointed at by r1 (timeInc address)
      add  r0, r0, #1         @ Increment r0 by 1
      str  r0, [r1]           @ Store the current r0 value back to the address pointed at by r1

      ldr  r2, =timer         @ Address of timer global variable stored in r1
      ldr  r1, [r2]           @ Load r0 with the address pointed at by r1 (timer address)
      cmp r0, r1              @ incremented value compared against timer value
      blt gameKeepsGoing      @ if less than timer then game continues
      bl gameOver             @ function called if player has not triggered win condition

      gameKeepsGoing:         @ exits here if game continues
      pop {lr}
      bx lr

      @@@@@@@
        @ Function Declaration : int gameOver()
        @ Description:           function for the ending of the game should the
        @                        player fail to activate win condition
        @
        @ Input:                 none
        @ Returns:               none

        @@ Function Header Block
            .align  2               @ Code alignment - 2^n alignment (n=2)
                                    @ This causes the assembler to use 4 byte alignment

            .syntax unified         @ Sets the instruction set to the new unified ARM + THUMB
                                    @ instructions. The default is divided (separate instruction sets)

            .global gameOver            @ Make the symbol name for the function visible to the linker

            .code   16              @ 16bit THUMB code (BOTH .code and .thumb_func are required)
            .thumb_func             @ Specifies that the following symbol is the name of a THUMB
                                    @ encoded function. Necessary for interlinking between ARM and THUMB code.
          @ This code is untested – test it out – can you make it work?
      gameOver:
        push {lr}

        ldr  r3, =gameOn          @ location of gameOn global variable stored in r3
        mov r0, #0
        str  r0, [r3]

        ldr r1, =LEDaddress       @ Load the GPIO address we need
        ldr r1, [r1]              @ Dereference r1 to get the value we want
        ldrh r0, [r1]             @ Get the current state of that GPIO (half word only)
        and r0, r0, #0x0
        strh r0, [r1]             @ Write the half word back to the memory address for the GPIO

        ldr r1, =target       @ Load the last light value to be shut on
        ldr r0, [r1]
        bl BSP_LED_Toggle

        pop {lr}
        bx lr

        @@@@@@@
          @ Function Declaration : int gameWin()
          @ Description:           function for the ending of the game should the
          @                        player succeed to activate win condition
          @
          @ Input:                 none
          @ Returns:               none

          @@ Function Header Block
              .align  2               @ Code alignment - 2^n alignment (n=2)
                                      @ This causes the assembler to use 4 byte alignment

              .syntax unified         @ Sets the instruction set to the new unified ARM + THUMB
                                      @ instructions. The default is divided (separate instruction sets)

              .global gameWin            @ Make the symbol name for the function visible to the linker

              .code   16              @ 16bit THUMB code (BOTH .code and .thumb_func are required)
              .thumb_func             @ Specifies that the following symbol is the name of a THUMB
                                      @ encoded function. Necessary for interlinking between ARM and THUMB code.
            @ This code is untested – test it out – can you make it work?
        gameWin:
          push {lr}

          ldr  r3, =gameOn          @ location of gameOn global variable stored in r3
          mov  r0, #2
          str  r0, [r3]

          ldr r1, =LEDaddress       @ Load the GPIO address we need
          ldr r1, [r1]              @ Dereference r1 to get the value we want
          ldrh r0, [r1]             @ Get the current state of that GPIO (half word only)
          @and r0, r0, #0x0
          orr r0, r0, #0xFF00      @ Use bitwise OR (ORR) to set the bit at 0x0100  @to reverse this use a bitwise AND 0x0

          strh r0, [r1]             @ Write the half word back to the memory address for the GPIO

          pop {lr}
          bx lr


      LEDaddress:
      .word 0x48001014

    .end
