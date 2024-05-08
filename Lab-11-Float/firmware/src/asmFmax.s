/*** asmFmax.s   ***/
#include <xc.h>
.syntax unified

@ Declare the following to be in data memory
.data  

@ Define the globals so that the C code can access them

.global f1,f2,fMax,signBitMax,biasedExpMax,expMax,mantMax
.type f1,%gnu_unique_object
.type f2,%gnu_unique_object
.type fMax,%gnu_unique_object
.type signBitMax,%gnu_unique_object
.type biasedExpMax,%gnu_unique_object
.type expMax,%gnu_unique_object
.type mantMax,%gnu_unique_object

.global sb1,sb2,biasedExp1,biasedExp2,exp1,exp2,mant1,mant2
.type sb1,%gnu_unique_object
.type sb2,%gnu_unique_object
.type biasedExp1,%gnu_unique_object
.type biasedExp2,%gnu_unique_object
.type exp1,%gnu_unique_object
.type exp2,%gnu_unique_object
.type mant1,%gnu_unique_object
.type mant2,%gnu_unique_object
 
.align
@ use these locations to store f1 values
f1: .word 0
sb1: .word 0
biasedExp1: .word 0  /* the unmodified 8b exp value extracted from the float */
exp1: .word 0
mant1: .word 0
 
@ use these locations to store f2 values
f2: .word 0
sb2: .word 0
exp2: .word 0
biasedExp2: .word 0  /* the unmodified 8b exp value extracted from the float */
mant2: .word 0
 
@ use these locations to store fMax values
fMax: .word 0
signBitMax: .word 0
biasedExpMax: .word 0
expMax: .word 0
mantMax: .word 0

.global nanValue 
.type nanValue,%gnu_unique_object
nanValue: .word 0x7FFFFFFF            

@ Tell the assembler that what follows is in instruction memory    
.text
.align

/********************************************************************
 function name: initVariables
    input:  none
    output: initializes all f1*, f2*, and *Max varibales to 0
********************************************************************/
.global initVariables
 .type initVariables,%function
initVariables:
    /* YOUR initVariables CODE BELOW THIS LINE! Don't forget to push and pop! */
    push {r4-r11,LR}
    
    // initialize all f1* variables to 0
    mov r4, #0
    ldr r5, =f1
    str r0, [r5]
    ldr r5, =sb1
    str r4, [r5]
    ldr r5, =biasedExp1
    str r4, [r5]
    ldr r5, =exp1
    str r4, [r5]
    ldr r5, =mant1
    str r4, [r5]
    
    // initalize all f2* variables to 0
    ldr r5, =f2
    str r1, [r5]
    ldr r5, =sb2
    str r4, [r5]
    ldr r5, =biasedExp2
    str r4, [r5]
    ldr r5, =exp2
    str r4, [r5]
    ldr r5, =mant2
    str r4, [r5]
    
    // initialize all *Max variables to 0
    ldr r5, =fMax
    str r4, [r5]
    ldr r5, =signBitMax
    str r4, [r5]
    ldr r5, =biasedExpMax
    str r4, [r5]
    ldr r5, =expMax
    str r4, [r5]
    ldr r5, =mantMax
    str r4, [r5]
    
    pop {r4-r11,LR}
    mov pc, lr	 /* asmEncrypt return to caller */
    /* YOUR initVariables CODE ABOVE THIS LINE! Don't forget to push and pop! */

    
/********************************************************************
 function name: getSignBit
    input:  r0: address of mem containing 32b float to be unpacked
            r1: address of mem to store sign bit (bit 31).
                Store a 1 if the sign bit is negative,
                Store a 0 if the sign bit is positive
                use sb1, sb2, or signBitMax for storage, as needed
    output: [r1]: mem location given by r1 contains the sign bit
********************************************************************/
.global getSignBit
.type getSignBit,%function
getSignBit:
    /* YOUR getSignBit CODE BELOW THIS LINE! Don't forget to push and pop! */
    push {r4-r11,LR}
    
    // registers for positive and negative sign bits
    mov r10, #0
    mov r11, #1
    mov r9, 0x80000000
    // get value of r0
    ldr r4, [r0]
    // get the most significant bit
    ands r4, r4, r9
    // if negative store 1 otherwise store 0
    cmp r4, r9
    beq is_neg
    str r10, [r1]
    b sb_end
is_neg:
    str r11, [r1]

sb_end:
    pop {r4-r11,LR}
    mov pc, lr	 /* asmEncrypt return to caller */
    /* YOUR getSignBit CODE ABOVE THIS LINE! Don't forget to push and pop! */
    

    
/********************************************************************
 function name: getExponent
    input:  r0: address of mem containing 32b float to be unpacked
            r1: address of mem to store BIASED
                bits 23-30 (exponent) 
                BIASED means the unpacked value (range 0-255)
                use exp1, exp2, or expMax for storage, as needed
            r2: address of mem to store unpacked and UNBIASED 
                bits 23-30 (exponent) 
                UNBIASED means the unpacked value - 127
                use exp1, exp2, or expMax for storage, as needed
    output: [r1]: mem location given by r1 contains the unpacked
                  original (biased) exponent bits, in the lower 8b of the mem 
                  location
            [r2]: mem location given by r2 contains the unpacked
                  and UNBIASED exponent bits, in the lower 8b of the mem 
                  location
********************************************************************/
.global getExponent
.type getExponent,%function
getExponent:
    /* YOUR getExponent CODE BELOW THIS LINE! Don't forget to push and pop! */
    push {r4-r11,LR}
    
    // load r0 for use
    ldr r4, [r0]
    // value to get exponential value
    ldr r5, =0x7F800000
    // isolate exponent bits
    and r4, r4, r5
    // shift right to move exponent to lower bits
    lsr r4, r4, #23
    // store biased exponent
    str r4, [r1]
    
    // if biased exponent is 0, unbiased exponent is -126
    cmp r4, #0
    beq biased_zero
    b biased_nonzero
    
biased_zero:
    mov r4, #-126
    str r4, [r2]
    b exp_end
    
biased_nonzero:
    // subtract 127 to get unbiased exponent
    sub r4, r4, #127
    // store unbiased exponent
    str r4, [r2]
    
exp_end:
    pop {r4-r11,LR}
    mov pc, lr	 /* asmEncrypt return to caller */
    /* YOUR getExponent CODE ABOVE THIS LINE! Don't forget to push and pop! */
   

    
/********************************************************************
 function name: getMantissa
    input:  r0: address of mem containing 32b float to be unpacked
            r1: address of mem to store unpacked bits 0-22 (mantissa) 
                of 32b float. 
                Use mant1, mant2, or mantMax for storage, as needed
    output: [r1]: mem location given by r1 contains the unpacked
                  mantissa bits
********************************************************************/
.global getMantissa
.type getMantissa,%function
getMantissa:
    /* YOUR getMantissa CODE BELOW THIS LINE! Don't forget to push and pop! */
    push {r4-r11,LR}

    ldr r6, =0x7FFFFF	    // used to get mantissa value
    ldr r7, =0x7F800000	    // used to check set exponent bits
    ldr r8, =0x800000	    // used to add 24th implied bit
    
    // load r0 for use
    ldr r4, [r0]
    mov r5, r4
    // get mantissa value
    and r4, r4, r6
    
    // check exponent bit
    and r5, r5, r7
    // compare with zero
    cmp r5, #0
    bne setbit23_1	    // if exponent bits are set
    beq setbit23_0	    // otherwise if exponent bits are not set
    
setbit23_1:
    // compare exponent bits with r5
    cmp r5, r7
    // if equal to 0, number must be inf
    cmpeq r4, #0
    beq inf_case
    // otherwise add 24th impled bit
    orr r4, r4, r8
    str r4, [r1]
    b mant_end
    
setbit23_0:
    // store r4 to r1
    str r4, [r1]
    b mant_end
    
inf_case:
    // handles if infinite
    mov r4, #0
    str r4, [r1]

mant_end:
    pop {r4-r11,LR}
    mov pc, lr	 /* asmEncrypt return to caller */
    /* YOUR getMantissa CODE ABOVE THIS LINE! Don't forget to push and pop! */
   


    
/********************************************************************
function name: asmFmax
function description:
     max = asmFmax ( f1 , f2 )
     
where:
     f1, f2 are 32b floating point values passed in by the C caller
     max is the ADDRESS of fMax, where the greater of (f1,f2) must be stored
     
     if f1 equals f2, return either one
     notes:
        "greater than" means the most positive numeber.
        For example, -1 is greater than -200
     
     The function must also unpack the greater number and update the 
     following global variables prior to returning to the caller:
     
     signBitMax: 0 if the larger number is positive, otherwise 1
     expMax:     The UNBIASED exponent of the larger number
                 i.e. the BIASED exponent - 127
     mantMax:    the lower 23b unpacked from the larger number
     
     SEE LECTURE SLIDES FOR EXACT REQUIREMENTS on when and how to adjust values!


********************************************************************/    
.global asmFmax
.type asmFmax,%function
asmFmax:   

    /* Note to Profs: Solution used to test c code is located in Canvas:
     *    Files -> Lab Files and Coding Examples -> Lab 11 Float Solution
     */

    /* YOUR asmFmax CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    push {r4-r11,LR}
    
    // call initVariables to initalize all variables to 0
    bl initVariables
    
    // unpack to f1*

    /* SIGN BIT */
    // r0: address of mem containing 32b float to be unpacked
    // r1: address of mem to store sign bit (bit 31).
    ldr r0, =f1
    ldr r1, =sb1
    bl getSignBit
    /* EXPONENT */
    // r0: address of mem containing 32b float to be unpacked
    // r1: address of mem to store BIASED
    // r2: address of mem to store unpacked and UNBIASED 
    ldr r0, =f1
    ldr r1, =biasedExp1
    ldr r2, =exp1
    bl getExponent
    /* MANTISSA */
    // r0: address of mem containing 32b float to be unpacked
    // r1: address of mem to store unpacked bits 0-22 (mantissa)
    ldr r0, =f1
    ldr r1, =mant1
    bl getMantissa
    
    
    // unpack to f2*

    /* SIGN BIT */
    // r0: address of mem containing 32b float to be unpacked
    // r1: address of mem to store sign bit (bit 31).
    ldr r0, =f2
    ldr r1, =sb2
    bl getSignBit
    /* EXPONENT */
    // r0: address of mem containing 32b float to be unpacked
    // r1: address of mem to store BIASED
    // r2: address of mem to store unpacked and UNBIASED 
    ldr r0, =f2
    ldr r1, =biasedExp2
    ldr r2, =exp2
    bl getExponent
    /* MANTISSA */
    // r0: address of mem containing 32b float to be unpacked
    // r1: address of mem to store unpacked bits 0-22 (mantissa)
    ldr r0, =f2
    ldr r1, =mant2
    bl getMantissa
    
    // load f1 and f2 to r4 and r5 respectively
    ldr r4, =f1
    ldr r4, [r4]   // load the value of f1
    ldr r5, =f2
    ldr r5, [r5]   // load the value of f2
    
    // check if f1 is infinity
    ldr r7, =0xFF000000	    // exponent for inf
    ldr r8, =0x007FFFFF	    // mantissa all zero
    
    ldr r9, =f1
    ldr r9, [r9]    // load value of f1
    and r10, r9, r7
    and r11, r9, r8
    cmp r10, r7
    beq f1_inf
    b f1_not_inf
    
f1_not_inf:
    // check if f2 is infinity
    ldr r9, =f2
    ldr r9, [r9]
    and r10, r9, r7
    and r11, r9, r8
    cmp r10, r7
    beq f2_inf
    b compare_f1_f2
    
f1_inf:
    // f1 is infinite
    ldr r4, =sb1
    ldr r4, [r4]
    cmp r4, #1
    beq f2_greater
    b f1_greater_or_equal
    
f2_inf:
    // f2 is infinite
    ldr r4, =sb2
    ldr r4, [r4]
    cmp r4, #1
    beq f1_greater_or_equal
    b f2_greater

compare_f1_f2:
    // check if either f1 or f2 is greater
    ldr r6, =sb1
    ldr r6, [r6]
    ldr r7, =sb2
    ldr r7, [r7]
    // is different sign, positive is greater
    cmp r6, r7
    beq same_sign
    cmp r6, #0
    bne f2_greater	// if f1 is negative and f2 is positive, f2 is greater
    b f1_greater_or_equal
    
same_sign:
    // check if sign is positive or negative
    cmp r6, #0
    beq both_positive
    b both_negative
    
both_positive:
    // handles positive signs
    cmp r4, r5
    bge f1_greater_or_equal
    b f2_greater
    
both_negative:
    // handles negative signs
    cmp r4, r5
    ble f1_greater_or_equal	// reverse comparison for negative numbers
    b f2_greater  

f1_greater_or_equal:
    // if f1 is greater or equal
    ldr r6, =fMax
    str r4, [r6]  // store f1 into fMax
    b update_fMax

f2_greater:
    // if f2 is greater or equal
    ldr r6, =fMax
    str r5, [r6]  // store f2 into fMax
    b update_fMax

update_fMax:
    // update all fMax* variables
    ldr r0, =fMax
    ldr r1, =signBitMax
    bl getSignBit
    
    ldr r0, =fMax
    ldr r1, =biasedExpMax
    ldr r2, =expMax
    bl getExponent
    
    ldr r0, =fMax
    ldr r1, =mantMax
    bl getMantissa
    
    b done

done:
    pop {r4-r11,LR}
    mov pc, lr	 /* asmEncrypt return to caller */
    /* YOUR asmFmax CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




