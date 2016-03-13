; #########################################################################
;
;   blit.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include blit.inc

.DATA

	;; If you need to, you can place global variables here

	
.CODE



;***************************************************************
;                       HELPER FUNCTIONS
;***************************************************************

;; *NOTE: copied these functions from lines.asm file, but changed the name
;; for some reason they didn't work when I tried to call from lines.asm

plot_blit PROC USES ebx ecx edx esi x:DWORD, y: DWORD, color: DWORD

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

plot_blit ENDP


int_to_fixed_blit PROC x:DWORD

    mov eax, x
    shl eax, 16

    ret
int_to_fixed_blit ENDP


;***************************************************************
;                       DRAW BLIT
;***************************************************************


BasicBlit PROC USES ebx ecx edx esi edi ptrBitmap:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD

    LOCAL dw_width:DWORD, dw_height:DWORD, dw_width_half:DWORD, dw_height_half:DWORD
    LOCAL yvalue:DWORD, xvalue:DWORD, xstart:DWORD
    LOCAL xmax:DWORD, ymax:DWORD
    LOCAL increment:DWORD
    LOCAL transparent:BYTE

    ;; *NOTE: This is different than the psuedocode, I followed a more intuitive
    ;; method that made sense to me. The rotate function follows the psuedocode
    ;; more closely



    mov esi, ptrBitmap
    mov eax, (EECS205BITMAP PTR[esi]).dwWidth
    mov dw_width, eax
    shr eax, 1
    mov dw_width_half, eax
    
    mov eax, (EECS205BITMAP PTR[esi]).dwHeight
    mov dw_height, eax
    shr eax, 1
    mov dw_height_half, eax



    mov ebx, xcenter
    sub ebx, dw_width_half
    mov xvalue, ebx
    mov xstart,ebx

    mov ebx, ycenter
    sub ebx, dw_height_half
    mov yvalue, ebx

    
    mov ebx, xvalue         ;setting up xmax
    add ebx, dw_width
    mov xmax, ebx

    mov ebx, yvalue         ;setting up ymax
    add ebx, dw_height
    mov ymax, ebx

    mov increment, 5 ;;starting at 5 for image adjustment
                     ;; (if increment was 0, it printed the image in a misplaced way)


forloopy:

    inc yvalue

    mov eax, ymax
    cmp yvalue, eax
    jg theend

    mov ebx, xstart
    mov xvalue, ebx

forloop_cond:

    
    inc xvalue
    mov ebx, xmax
    cmp xvalue, ebx
    jg  forloopy

forloop:
    ;; now compare the two arrays

    

    mov cl, (EECS205BITMAP PTR[esi]).bTransparent
    mov transparent, cl
    

    mov edx, increment
    mov edi, (EECS205BITMAP PTR[esi+edx]).lpBytes
    ;;mov ebx, di
    inc increment
    
    ;; comparing if dot should be transparent or not
    mov ebx, edi
    cmp bl, transparent
    je forloop_cond

    
    ;; now plot
    invoke plot_blit, xvalue, yvalue, edi

    jmp forloop_cond
    


theend:

    ret  	;;  Do not delete this line!
BasicBlit ENDP





;***************************************************************
;                         ROTATE
;***************************************************************


RotateBlit PROC lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT

    LOCAL dw_width:DWORD, dw_height:DWORD, dw_width_half:DWORD, dw_height_half:DWORD
    LOCAL cosa:FXPT, sina:FXPT, lpBytes:DWORD
    LOCAL shiftX:DWORD, shiftY:DWORD, dstWidth:DWORD, dstHeight:DWORD, dstX:DWORD, dstY:DWORD
    LOCAL srcX:DWORD, srcY:DWORD, screenX:DWORD, screenY:DWORD
    LOCAL transparent:BYTE

    ;; *NOTE: This follows the psuedocode more closely

    INVOKE FixedCos, angle       ;; calculating cosa & sina
    mov cosa, eax
    INVOKE FixedSin, angle
    mov sina, eax 
    
    mov esi, lpBmp
    
    mov ebx, (EECS205BITMAP PTR[esi]).lpBytes
    mov lpBytes, ebx
    mov bl, (EECS205BITMAP PTR[esi]).bTransparent
    mov transparent, bl 

    
    mov esi, lpBmp
    mov eax, (EECS205BITMAP PTR[esi]).dwWidth       ;;** width, width/2
    mov dw_width, eax
    shr eax, 1
    mov dw_width_half, eax
    
    mov eax, (EECS205BITMAP PTR[esi]).dwHeight      ;; hegit, height/2
    mov dw_height, eax
    shr eax, 1
    mov dw_height_half, eax


   
    mov eax, dw_width        ; calculating shiftX
    mov ebx, cosa            ;; shiftX = (EECS205BITMAP PTR [esi]).dwWidth * cosa / 2 - (EECS205BITMAP
    imul ebx                 ;; PTR [esi]).dwHeight * sina / 2
    ;; to save sign
    sar eax, 17             
    mov esi, eax

    mov eax, dw_height
    mov ebx, sina
    imul ebx
    ;; to save sign
    sar eax, 17     

    sub esi, eax
    mov shiftX, esi 

    mov eax, dw_height       ; calculating shiftY
    mov ebx, cosa            ;; shiftY = (EECS205BITMAP PTR [esi]).dwHeight * cosa / 2 + (EECS205BITMAP
                             ;; PTR [esi]).dwWidth * sina / 2
    imul ebx
    sar eax, 17
    mov esi, eax

    mov eax, dw_width
    mov ebx, sina
    imul ebx
    sar eax, 17

    add esi, eax
    mov shiftY, esi 


    mov eax, dw_width   ;; calculating dstWidth & dstHeight (same value)
    add eax, dw_height  
    mov dstWidth, eax
    mov dstHeight, eax 


forloop_cond_rotate:
    mov ebx, dstHeight
    neg ebx 
    mov dstY, ebx

forloop_y_rotate:
    mov ecx, dstWidth
    neg ecx
    mov dstX, ecx

forloop_x_rotate:

    mov eax, dstX       ;; calculating srcX
    imul cosa           ;; srcX = dstX*cosa + dstY*sina
    sar eax, 16
    mov ebx, eax
    mov eax, dstY
    imul sina
    sar eax, 16
    add eax, ebx
    mov srcX, eax

    
    mov eax, dstY       ;; calculate srcY
    imul cosa           ;; srcY = dstY*cosa - dstX*sina
    sar eax, 16
    mov ebx, eax
    mov eax, dstX
    imul sina
    sar eax, 16
    sub ebx, eax
    mov srcY, ebx



    ;; ******************************
    ;; **** now the HUGE if statement
    ;;      a butt load of checks
    ;; ******************************
    
    ;; is srcX >= 0?
    mov ebx, srcX               
    cmp ebx, 0
    jl Increment
    
    ;; is srcX < dwWidth?
    cmp ebx, dw_width            
    jge Increment

    ;; is srcY >= 0?
    mov ebx, srcY              
    cmp ebx, 0
    jl Increment

    ;; is srcY < dwHeight?
    cmp ebx, dw_height           
    jge Increment

    ;; is screenX >=0 and screenX < 639?
    xor edx, edx
    sub edx, shiftX
    add edx, xcenter
    add edx, dstX 
    mov screenX, edx
    cmp edx, 0               
    jl Increment  
    cmp edx, 639                
    jge Increment

    ;; is  screenY >= 0 and screenY < 479?
    xor edx, edx
    sub edx, shiftY
    add edx, dstY
    add edx, ycenter
    mov screenY, edx
    cmp edx, 0                  
    jl Increment
    cmp edx, 479                
    jge Increment
   
    
    ;; transparency check
    mov eax, srcY
    mov esi, dw_width
    mul esi
    add eax, srcX
    add eax, lpBytes ;; adjusting eax for specific index 
                     ;; ((y * dwWidth) + x) => eax

    mov cl, BYTE PTR[eax]
    cmp cl, transparent
    je Increment
    
    ;; now FINALLY plot!
    INVOKE plot_blit, screenX, screenY, cl

Increment:
    inc dstX
    mov ebx, dstX               ;; increments width 
    cmp ebx, dstWidth
    jl forloop_x_rotate         ;; go back to x forloop

    inc dstY
    mov ebx, dstY               ;; increments height
    cmp ebx, dstHeight
    jl forloop_y_rotate         ;; go back to y forloop
     
	ret  	;;  Do not delete this line!
	
RotateBlit ENDP


;***************************************************************
;                       COLLISSION
;***************************************************************


CheckIntersectRect PROC USES edi esi one:PTR EECS205RECT, two:PTR EECS205RECT

    ;; realized probably could do this in an easier way
    ;; Prof Russ: "..when are the squares not colliding?"

    xor eax, eax
    mov eax, one
    mov ebx, two
    
    mov ecx, (EECS205RECT PTR[eax]).dwLeft
    mov edx, (EECS205RECT PTR[ebx]).dwLeft
   
    cmp ecx, edx 
    jg twoleft ;; if gt, check two's left
    
oneleft:
    mov ecx, (EECS205RECT PTR[eax]).dwRight
    cmp ecx, edx
    jge bothtop
    jmp nocollision
    
twoleft:
    mov edx, (EECS205RECT PTR[ebx]).dwRight
    cmp edx, ecx ;; two's right and one's left
    jge bothtop
    jmp nocollision
    
bothtop:
    mov ecx, (EECS205RECT PTR[eax]).dwTop
    mov edx, (EECS205RECT PTR[ebx]).dwTop
    cmp ecx, edx    
    jg twotop
    
onetop:
    mov ecx, (EECS205RECT PTR[eax]).dwBottom
    cmp ecx, edx
    jge collision
    jmp nocollision
    
twotop:
    mov edx, (EECS205RECT PTR[ebx]).dwBottom
    cmp edx, ecx
    jge collision
    jmp nocollision
    
collision:
    ;; showing blue and red boxes
    mov eax, 1
    jmp theend
    
nocollision:
    mov eax, 0

theend:


	ret  	;;  Do not delete this line!
	
CheckIntersectRect ENDP

END
