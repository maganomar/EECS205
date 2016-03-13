; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


        ;;    **************************
        ;;          MAGAN OMAR
        ;;    **************************

        ;;   ** FROM HW 1

include stars.inc

.DATA

	;; If you need to, you can place global variables here

.CODE

DrawStarField proc

	;; Place your code here

      invoke DrawStar,50,50
      invoke DrawStar,55,78
      invoke DrawStar,94,68
      invoke DrawStar,110,88
      invoke DrawStar,75,105
      invoke DrawStar,52,118
      invoke DrawStar,60,157
      invoke DrawStar,101,136
      invoke DrawStar,120,120
      invoke DrawStar,148,114
      invoke DrawStar,151,136
      invoke DrawStar,124,170
      invoke DrawStar,117,222
      invoke DrawStar,99,273
      invoke DrawStar,188,224
      invoke DrawStar,241,191
      invoke DrawStar,259,134
      invoke DrawStar,193,99
      invoke DrawStar,248,252
      invoke DrawStar,231,286
      invoke DrawStar,210,312
      invoke DrawStar,278,335
      invoke DrawStar,320,310
      invoke DrawStar,302,267
      invoke DrawStar,270,300
      invoke DrawStar,313,218
      invoke DrawStar,305,174
      invoke DrawStar,301,87
      invoke DrawStar,348,53
      invoke DrawStar,344,122
      invoke DrawStar,386,220
      invoke DrawStar,400,160
      invoke DrawStar,400,90
      invoke DrawStar,417,42
      invoke DrawStar,443,248
      invoke DrawStar,466,188
      invoke DrawStar,467,131
      invoke DrawStar,487,219
      invoke DrawStar,528,137
      invoke DrawStar,525,97
      invoke DrawStar,537,46
      invoke DrawStar,100,100
      invoke DrawStar,120,120
      invoke DrawStar,130,130
      invoke DrawStar,140,140


    invoke DrawStar,630,470


	ret  			; Careful! Don't remove this line
DrawStarField endp


AXP	proc a:FXPT, x:FXPT, p:FXPT

	;; Place your code here

      mov eax, a    ; puts a in register eax
      mov ebx, x    ; puts x in register ebx    
      
      imul ebx      ; multiplies x and a, puts it in register eax [edx,eax]

      and edx, 0FFFFh       ; clears bits to only get edx<15;0>
      and eax, 0FFFF0000h   ; clears bits to only get eax<31;16>
      
      sal edx, 16           ; shifts the bits, in order to add them nicely
      sar eax, 16
        

      
      add eax, edx          ; combines eax & edx into eax

      add eax, p            ; adds p to final result
      
	;; Remember that the return value should be copied in to EAX
	
	ret  			; Careful! Don't remove this line	
AXP	endp

	

END
