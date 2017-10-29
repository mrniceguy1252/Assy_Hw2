@ vim:ft=armv8

	.arch  armv8-a
	.fpu   neon-fp-armv8
	.cpu   cortex-a53
	.syntax unified
	.global main

	.text

/* Function Encrpyt Characters Array */
/* Sets random number based on time y */
/* Parmeter: r0 is set to the length of the char array */ 
/* Paramter: No other paramters set */
encryptText:
	stmfd sp!, {r4,r5,r6,r7,r8,lr}

	mov	r5, r0		/* Store char array length */
	ldr	r6, =mask	/* Load bit mask */
	ldr	r6, [r6]

	/* Calculate Random Number */
	mov	r0, #0
	bl	time		/* Get time */
	bl	srand		/* Seed random number generator with time */
	
	bl	rand		/* Generate random number */
	ands	r7, r0, r6	/* Store value of bit mask and rand */	

	/* Store Encryption Key */
	ldr	r8, =keyValue
	str	r7, [r8]	

	mov	r1, #0		/* Iterator for Counting Bytes Transformed */
	ldr	r2, =charArray	/* Char array for holding capture bytes */	

encryptLoop:
	ldrb	r3, [r2, r1]	/* Load char value from char array */ 
	add	r3, r3, r7	/* Add random value to number pulled from char array */
	cmp	r3, r6 		/* Compare value to 127 if gt subtract */ 
	subge	r3, r3, r6	

	strb	r3, [r2, r1]	/* Store back into array */

  	add	r1, r1, #1	/* Iterate counter */
	cmp	r1, r5		/* Compare to size of char array */ 
	blt	encryptLoop
encryptEnd:
	
	ldmfd sp!, {r4,r5,r6,r7,r8,lr}
	mov  pc, lr


/* Function Read Text */
/* Opens file, reads contents and stores them to a memory buffery */
/* Parmeter: r0 is set to the text file name */ 
/* Paramter: No other paramters set */
/* Return: bool if programmed passed */
readText:
	stmfd sp!, {r4,r5,r6,lr}

	mov	r5, #0		/* Iterator for Counting Bytes Captured */
	ldr	r6, =charArray	/* Char array for holding capture bytes */	

	/* Set ReadMode Open File */
	ldr	r1, =rmode  
	bl	fopen

	mov	r4, r0		/* Save file pointer for later use */

readLoop:
	mov	r0, r4
	ldr	r1, =infmtC
	ldr	r2, =debugNum
	bl	fscanf
	cmp	r0, #1		/* When r0 value not equal to 1 stop read */ 
	bne	readEnd
   
	/* Print Each character */
	ldr	r0, =outfmtC
	ldr	r1, =debugNum
	ldr	r1, [r1]
	bl	printf

	/* Store Each Character to Byte Array */
	ldr	r1, =debugNum
	ldr	r1, [r1]
	strb	r1, [r6, r5]	

	add	r5, r5, #1
	b	readLoop
readEnd:
	mov	r0, r4
	bl	fclose		/* Close file */

	/* TODO Set error condition if the value exceeds the maximum width or height */

	/* Store Message Length */
	ldr	r1, =msgLength	
	str	r5, [r1]			

	mov	r0, r5		/* Move Size Counter */
	bl	encryptText	/* Run Text Encrpytion */

	/* Print Name */
	ldr	r0, =outfmtS	
	ldr	r1, =charArray
	bl	printf	

	ldmfd sp!, {r4,r5,r6,lr}
	mov  pc, lr

/* Main Program Call */
main:
	/* Print Image File Name */
	ldr	r0, =outfmtImageFN	
	ldr	r1, =imageFile
	bl	printf	

	/* Print Secret Text File Name */
	ldr	r0, =outfmtSecretFN	
	ldr	r1, =textFile
	bl	printf	

	/* Print Secret Image File Name */
	ldr	r0, =outfmtSecretFN	
	ldr	r1, =secretImage
	bl	printf	

	/* Load Text File and Encrypt Text */
	ldr	r0, =textFile
	bl	readText

	/* Finish Execution */
	mov	r0, #0
	mov	r7, #1
	svc	#0

.data

/* System Message */
syscomm:   
	.asciz  "gpicview marcie_secret.pgm"

/* Original Image File */
imageFile:
	.asciz	"marcie.pgm"

/* Secret Message Text File */
textFile:
	.asciz	"msg.txt"

/* Image with Secret Message */
secretImage:
	.asciz	"marcie_secret.pgm"

/* Output Format for Image File Name */
outfmtImageFN:
	.asciz	"Image File Name: %s \n"

/* Output Format for Secret Text File Name */
outfmtSecretFN:
	.asciz	"Secret Text File Name: %s \n"

/* Output Format for Secret Text File Name */
outfmtSecretImageFN:
	.asciz	"Secret Image File Name: %s \n"

/* Error Message for End of File */
e_errorMsg:
	.asciz	"Encryption: Error message \n"	

/* Format for Reading Characters */
infmtC:	.asciz	"%c"

/* Format for Printing Out Characters */
outfmtC:	.asciz	"%c\n"

/* Format for Printing Out Strings */
outfmtS:	.asciz	"%s\n"

/* Read Mode Format */
rmode:		.asciz  "rb"

/* Image File Width */
debugNum:	.word 0

/* Char Array */
charArray:	.space 120

/* Bit Mask to 127 */
mask:		.word 0x0000007f

/* Length of Message */
msgLength:	.word 0

/* Key Value for Cipher */
keyValue:	.word 0
