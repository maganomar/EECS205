; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA
;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  256 / PI   (use this to find the table entry for a given angle
	                        ;;              it is easier to use than divison would be)

	;; If you need to, you can place global variables here


	
.CODE
	


        ;;    **************************
        ;;         NAME: MAGAN OMAR
        ;;    **************************


FixedSin PROC USES edi esi edx angle:FXPT
    mov eax, PI_INC_RECIP
    mov edi, angle

zero_to_halfpi:

    cmp edi, 0
    jl  addtwopi
    cmp edi, PI_HALF
    jg halfpi_to_pi

    mul edi
    movzx eax, WORD PTR[SINTAB + 2*edx]
    
    jmp theend


halfpi_to_pi:
    cmp edi, PI
    jg pi_to_3qpi

    neg edi
    add edi, PI
    mul edi
    movzx eax, WORD PTR[SINTAB + 2*edx]
    jmp theend

pi_to_3qpi:

    mov esi, PI
    add esi, PI_HALF
    cmp edi, esi ; comparing 3pi/2 to angle
    jg threeqpi_to_2pi

    
    sub edi, PI
    
    mul edi
    movzx eax, WORD PTR[SINTAB + 2*edx]
    neg eax       
    jmp theend


threeqpi_to_2pi:

    cmp edi, TWO_PI
    jg sub2pi

    sub edi, PI

    neg edi
    add edi, PI
    mul edi
    movzx eax, WORD PTR[SINTAB + 2*edx]
    neg eax       
    jmp theend

sub2pi:
    ;; needed if angle is over 2pi, so it can be calculated
    sub edi, TWO_PI
    jmp zero_to_halfpi

addtwopi:
    ;; needed of angle is less than 0, so it can be calculated
    add edi, TWO_PI
    jmp zero_to_halfpi        

returnzero:
    mov eax, 0


theend:
    

	ret        	;;  Don't delete this line...you need it	
FixedSin ENDP 
	
FixedCos PROC angle:FXPT

    mov eax, angle
    add eax, PI_HALF
    invoke FixedSin, eax
	
	ret        	;;  Don't delete this line...you need it		
FixedCos ENDP	




            ;; ******************
            ;; ** DRAWING LINE **
            ;; ******************	

plot PROC USES ebx ecx edx esi x:DWORD, y: DWORD, color: DWORD

    ;; write check to see if it's in bounds
    ;; assuming it is

    ;; calculate offset

    cmp x, 639
    jg theend_plot
    cmp x, 0
    jl theend_plot
    cmp y, 479
    jg theend_plot
    cmp y, 0
    jl theend_plot

    mov ebx, 640
    mov eax, y
    mul ebx
    add eax, x

    mov ecx, color
    
    mov esi, ScreenBitsPtr
    mov BYTE PTR [esi + eax], cl

theend_plot:
    mov eax, 0
    
    ret

plot ENDP

fixed_to_int PROC x:DWORD

    mov eax, x
    shr eax, 16

    ret
fixed_to_int ENDP



int_to_fixed PROC x:DWORD

    mov eax, x
    shl eax, 16

    ret
int_to_fixed ENDP


;; **** DRAWING LINE ****

DrawLine PROC USES esi edi ebx ecx edx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
    LOCAL i:DWORD, fixed_inc:FXPT, fixed_j:FXPT, temp: DWORD, temp2: DWORD

    mov edi, y1
    sub edi, y0     ; edi = y1-y0
    
    mov esi, x1
    sub esi, x0     ; esi = x1-x0

    cmp edi, 0
    jl negatey

thispart:
    cmp esi, 0
    jl negatex

    jmp compare1

negatey:
    neg edi
    jmp thispart

negatex:
    neg esi
    jmp compare1

compare1:

    cmp edi, esi    ; y1-y0(edi) < x1-x0(esi)?
    jl partone 

    jmp parttwo
    

partone:

    ;; continue into first part of if statement:


    ;; moving y1-y0, and x1-x0 back to not absolute value
    
    mov edi, y1
    sub edi, y0     ; edi = y1-y0
    
    mov esi, x1
    sub esi, x0     ; esi = x1-x0



    
    invoke int_to_fixed, esi ;; x1-x0 -> esi -> fixedpt
    mov esi, eax
    ;invoke int_to_fixed, edi

    mov edx, edi
    mov eax, 0
    
    ; y1-y1 in fixed point is in eax now
    
    idiv esi
    mov fixed_inc, eax

    ;; second if statement
    mov ebx, x0
    cmp x1, ebx
    jl y1_to_fixedj
    jmp y0_to_fixedj

y1_to_fixedj:    
    ;; swap x0 and x1 first
    mov ebx, x0
    mov ecx, x1
    mov x0, ecx
    mov x1, ebx
    
    invoke int_to_fixed, y1
    mov fixed_j, eax
    jmp forloop_plot
    
y0_to_fixedj:
    invoke int_to_fixed, y0
    mov fixed_j, eax



forloop_plot:

    mov ebx, x0
    mov i, ebx      ;; initilizing i = x0
    mov ecx, x1
   
actualloop:
    
    invoke fixed_to_int, fixed_j
        
    invoke plot, i, eax, color
     
    mov ecx, fixed_inc
    add fixed_j, ecx

    mov esi, 1
    add i, esi ;; i = i + 1 

    mov edx, x1
    cmp i, edx
  
    jle actualloop
    jmp theend

    ;; Ignore, just for testing purposes
    ;jmp testplot2


;; Parts below just for testing purposes
COMMENT @   
testplot:
    invoke plot, 50, 50, color
    invoke plot, 50, 51, color
    invoke plot, 50, 52, color
    invoke plot, 50, 53, color
    invoke plot, 50, 54, color
    invoke plot, 50, 55, color
    invoke plot, 50, 56, color
    invoke plot, 50, 57, color
    invoke plot, 50, 58, color
    invoke plot, 50, 59, color
    invoke plot, 50, 60, color
    jmp theend

testplot2:
    invoke plot, 250, 50, color
    invoke plot, 250, 51, color
    invoke plot, 250, 52, color
    invoke plot, 250, 53, color
    invoke plot, 250, 54, color
    invoke plot, 250, 55, color
    invoke plot, 250, 56, color
    invoke plot, 250, 57, color
    invoke plot, 250, 58, color
    invoke plot, 250, 59, color
    invoke plot, 250, 60, color
    jmp theend

@

parttwo:



    ;; comparing if y1 equals y0
    mov edx, y1
    cmp y0, edx
    je theend

    mov edi, y1
    sub edi, y0     ; edi = y1-y0
    
    mov esi, x1
    sub esi, x0     ; esi = x1-x0


    invoke int_to_fixed, edi ;; x1-x0 -> esi -> fixedpt
    mov edi, eax
    ;invoke int_to_fixed, edi
    mov edx, esi
    mov eax, 0
    
    ; y1-y1 in fixed point is in eax now
    
    idiv edi
    mov fixed_inc, eax


    mov ecx, y1
    cmp y0, ecx
    jle x0_to_fixedj

x1_to_fixedj:
    ;; swap
    mov ebx, y0
    mov ecx, y1
    mov y0, ecx
    mov y1, ebx

    invoke int_to_fixed, x1
    mov fixed_j, eax
    jmp forloop_plottwo

x0_to_fixedj:
    invoke int_to_fixed, x0
    mov fixed_j, eax
    jmp forloop_plottwo




forloop_plottwo:


    mov ebx, y0
    mov i, ebx      ;; initilizing i = y0
   
actuallooptwo:


    invoke fixed_to_int, fixed_j

    
    invoke plot, eax, i, color
    
    mov ecx, fixed_inc
    add fixed_j, ecx

    mov esi, 1
    add i, esi
    mov edx, y1
    cmp i, edx
    jle actuallooptwo

    jmp theend
    
    ;; Ignore, just for testing purposes
    ;jmp testplot

   
theend:


    ret        	;;  Don't delete this line...you need it
DrawLine ENDP


END
