TITLE Arrays and Sorting     (program5.asm)

; Author: Ken Hall
; CS 271 400                 Date: 3/04/2018

; Description:
; 1. Introduce the program.
; 2. Get a user request in the range [min = 10 .. max = 200].
; 3. Generate request random integers in the range [lo = 100 .. hi = 999], storing them in consecutive elements
; of an array.
; 4. Display the list of integers before sorting, 10 numbers per line.
; 5. Sort the list in descending order (i.e., largest first).
; 6. Calculate and display the median value, rounded to the nearest integer.
; 7. Display the sorted list, 10 numbers per line.

INCLUDE Irvine32.inc

	REQUEST_MIN = 10
	REQUEST_MAX = 200
	RAND_INT_LO = 100
	RAND_INT_HI = 999
	RAND_INT_RANGE = 900

.data

	intro_1				BYTE			"Arrays and Sorting								By Ken Hall", 0
	
	userInstruct_1		BYTE			"This program generates random numbers in the range 100 - 999,", 0
	userInstruct_2		BYTE			"displays the original list, sorts the list, and calculates the median", 0
	userInstruct_3		BYTE			"before displaying the list sorted in descending order.", 0

	userPrompt_1		BYTE			"How many numbers should be generated? [10 - 200]", 0
	userPromptErr		BYTE			"Invalid input", 0

	unsortedReport		BYTE			"The unsorted random numbers: ", 0
	medianReport		BYTE			"The median: ", 0
	sortedReport		BYTE			"The sorted random numbers: ", 0

	outro_1				BYTE			"Goodbye!", 0
	theArray			DWORD			REQUEST_MAX					DUP(?)

.code
main PROC

	call				Randomize

	push				OFFSET intro_1								;greet the user
	call				intro

	push				OFFSET userInstruct_3						;provide instructions to user
	push				OFFSET userInstruct_2
	push				OFFSET userInstruct_1
	call				displayInstructions

	push				OFFSET userPromptErr						;get input from user
	push				OFFSET userPrompt_1
	push				REQUEST_MIN
	push				REQUEST_MAX
	call				getData

	;					number of ints on stack						;build the array with random ints
	push				RAND_INT_LO
	push				RAND_INT_RANGE
	push				OFFSET theArray
	call				fillArray

	;					number of ints in theArray on stack			;display the unsorted array
	push				OFFSET theArray
	push				OFFSET unsortedReport
	push				0
	call				displayList

	;					number of ints in theArray on stack			;sort the array in descending order
	push				OFFSET theArray
	call				sortList

	;					number of ints in theArray on stack			;calculate and display the median
	push				OFFSET theArray
	push				OFFSET medianReport
	call				displayMedian

	;					number of ints in theArray on stack			;display the sorted array
	push				OFFSET theArray
	push				OFFSET sortedReport
	push				0
	call				displayList

	push				OFFSET outro_1								;say farewell to the user and exit
	call				displayOutro
	
	exit	; exit to operating system

main ENDP

;--------
;PROCEDURES
;--------


intro PROC
;--------
;DESCRIPTION: Greets the user
;RECEIVES: String on the stack containing a greeting
;RETURNS: None
;PRECONDITIONS: None
;--------
	push				ebp
	mov					ebp, esp
	push				edx
	mov					edx, [ebp+8]								;load the greeting into register
	call				WriteString
	call				CrLf
	call				CrLf
	call				CrLf
	pop					edx
	pop					ebp
	ret 4															;wipe greeting from stack
intro ENDP	


displayInstructions PROC
;--------
;DESCRIPTION: Displays instructions regarding input to user
;RECEIVES: 3 strings on the stack containing instructions
;RETURNS: None
;PRECONDITIONS: None
;--------
	push				ebp
	mov					ebp, esp
	push				edx
	mov					edx, [ebp+8]								;load instructions into register and write to console
	call				WriteString
	call				CrLf
	mov					edx, [ebp+12]
	call				WriteString
	call				CrLf
	mov					edx, [ebp+16]
	call				WriteString
	call				CrLf
	call				CrLf
	pop					edx
	pop					ebp
	ret					12											;wipe instructions from stack
displayInstructions ENDP


getData PROC
;--------
;DESCRIPTION: processes an integer input from the user
;RECEIVES: 2 strings on the stack defining prompt and invalid input, 2 constants to bound the range of the input
;RETURNS: validated input on the stack
;PRECONDITIONS: None
;--------
	push				ebp
	mov					ebp, esp
	push				edx
	push				ebx
	push				eax
tryAgain:
	mov					edx, [ebp+16]								;load informational string into register and display
	call				WriteString
	call				ReadInt
	mov					ebx, [ebp+12]								;move lower boundary into register
	cmp					eax, ebx
	jl					invalid
	mov					ebx, [ebp+8]								;move upper boundary into register
	cmp					eax, ebx
	jg					invalid
	mov					[ebp+20], eax								;move validated integer onto the stack
	pop					eax
	pop					ebx
	pop					edx
	pop					ebp
	call				CrLf
	ret					12											;wipe string and boundaries from stack
invalid:
	mov					edx, [ebp+20]								;load "invalid" informational string into register and display
	call				WriteString
	call				CrLf
	jmp					tryAgain
getData ENDP


fillArray PROC
;--------
;DESCRIPTION: fills an array with random numbers
;RECEIVES: (via the stack) the number of items to fill the array with, two constants defining the boundaries of the random number, and the address of the array
;RETURNS: array filled with random numbers at the address specified, the number of items the array contains (via the stack)
;PRECONDITIONS: None
;--------
	push				ebp
	mov					ebp, esp
	push				eax
	push				ebx
	push				ecx
	push				edx
	mov					ecx, [ebp+20]								;load number of integers into counter
	mov					ebx, 0
	mov					edx, [ebp+8]								;load array address into register
insertElement:
	mov					eax, [ebp+12]								;load range of RANDOM int into register
	call				RandomRange						
	add					eax, [ebp+16]								;add floor of RANDOM int into register
	mov					[edx+ebx], eax								;store the generated value to the appropriate array element
	add					ebx, 4										;prepare to work with the next array element
	loop				insertElement
	pop					edx
	pop					ecx
	pop					ebx
	pop					eax
	pop					ebp
	ret					12	

fillArray ENDP


displayList PROC
;--------
;DESCRIPTION: displays the items in an array
;RECEIVES: (via the stack) the address of the array, the number of items in the array, 
;RETURNS: number of items in the array (via the stack)
;PRECONDITIONS: space for a DWORD local variable, used for keeping a counter for defining rows
;--------
	push				ebp
	mov					ebp, esp
	push				eax
	push				ebx
	push				ecx
	push				edx
	call				CrLf
	mov					edx, [ebp+12]
	call				WriteString
	call				CrLf
	mov					ebx, 0
	mov					ecx, [ebp+20]
	mov					edx, [ebp+16]

displayNum:
	mov					eax, [edx+ebx]
	call				WriteInt
	mov					eax, 9
	call				WriteChar
	add					ebx, 4
	mov					eax, [ebp+8]
	inc					eax
	cmp					eax, 10
	je					newLine
	mov					[ebp+8], eax
	loop				displayNum

	pop					edx
	pop					ecx
	pop					ebx
	pop					eax
	pop					ebp
	ret					12
newLine:
	call				CrLf
	mov					eax, 0
	mov					[ebp+8], eax
	loop				displayNum

	pop					edx
	pop					ecx
	pop					ebx
	pop					eax
	pop					ebp
	ret					12
displayList ENDP


displayOutro PROC
;--------
;DESCRIPTION: indicates to the user that the program is ending
;RECEIVES: (via the stack) a string containing the outro text
;RETURNS: NONE
;PRECONDITIONS: NONE
;--------
	push				ebp
	mov					ebp, esp
	push				edx
	call				CrLf
	call				CrLf
	mov					edx, [ebp+8]									;load the string into register and display
	call				WriteString
	call				CrLf
	pop					edx
	pop					ebp
	ret					4
displayOutro ENDP


sortList PROC
;--------
;DESCRIPTION: sorts the integers in an array in descending order
;RECEIVES: (via the stack) the address of the array, and the number of items in the array
;RETURNS: at the address of the array, the array sorted in descending order; at the stack, the number of items in the array
;PRECONDITIONS: NONE
;--------
	push				ebp
	mov					ebp, esp
	push				eax
	push				ecx
	push				edx

	mov					ecx, [ebp+12]									;load the number of elements into the array
	dec					ecx
fromTheTop:
	push				ecx												;store outer loop counter
	mov					esi, [ebp+8]									;load the address of the first array element

swapCheck:
	mov					eax,[esi]										;load the contents of the source index into register
	cmp					[esi+4], eax									;compare the contents to the contents of the next element in the array
	jl					noSwap
	xchg				eax,[esi+4]										;swap the array items
	mov					[esi],eax										;move the contents of the current array item to the address indiciated by esi

noSwap:
	add					esi, 4											;advance to the next item in the array
	loop				swapCheck
	pop					ecx												;reload outer loop counter
	loop				fromTheTop

	pop					edx
	pop					ecx
	pop					eax
	pop					ebp
	ret					4
sortList ENDP


displayMedian PROC
;--------
;DESCRIPTION: calculates and displays the median of an array
;RECEIVES: (via the stack), the address of the array, and the number of items in the array
;RETURNS:  the number of items in the array, at the stack
;PRECONDITIONS: NONE
;--------
	push				ebp
	mov					ebp, esp
	push				eax
	push				ebx
	push				ecx
	push				edx
	mov					edx, [ebp+8]									;load string into register and write to console
	call				CrLf
	call				CrLf
	call				WriteString
	mov					edx, 0
	mov					ebx, 2
	mov					eax, 0
	mov					eax, [ebp+16]									;load number of elements to register
	div					bx
	mov					ebx, 4
	cmp					dx, 0
	je					evenNumberOfElements
	jmp					oddNumberOfElements
endProc:
	pop					edx
	pop					ecx
	pop					ebx
	pop					eax
	pop					ebp
	ret					8

evenNumberOfElements:
	mul					bx												;find middle two elements
	mov					ebx, [ebp+12]
	mov					ecx, [ebx+eax]
	mov					edx, [ebx+eax-4]
	add					ecx, edx										;average the two elements
	mov					edx, 0
	mov					eax, ecx
	mov					ecx, 2
	div					cx
	call				WriteDec										;display median
	call				CrLf
	jmp					endProc

oddNumberOfElements:
	mul					bx												;find middle element
	mov					ebx, [ebp+12]
	mov					eax, [ebx+eax]
	call				WriteDec										;display median
	call				CrLf
	jmp					endProc
displayMedian ENDP
END main
