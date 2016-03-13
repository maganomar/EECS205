; #########################################################################
;
;   game.asm - Assembly file for EECS205 Assignment 4/5
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
include game.inc
include keys.inc
include sprites.asm


; For Drawing Text
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib

; For Playing Sound
include \masm32\include\windows.inc
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib	



.DATA
	
;; If you need to, you can place global variables here


;; EECS205RECT structures for collision
drakerect EECS205RECT<?,?,?,?>
meekrect EECS205RECT<?,?,?,?>
nickirect EECS205RECT<?,?,?,?>
recttest EECS205RECT<485, 315, 620, 470> ;; test for collision


;; STRINGS
whatStr BYTE "YOU LOSE", 0
toomuchstr BYTE "Try not to think about it too much...", 0
restartstr BYTE "Press Spacebar to restart this level!", 0

;; DRAKE SPRITE position
xpos DWORD ?
ypos DWORD ?

;; MEEK SPRITE position
xpos_meek DWORD ?
ypos_meek DWORD ?

;; NICKI SPRITE position
xpos_nicki DWORD 550
ypos_nicki DWORD 375

;; SONGS
hotlinebling BYTE "hotlinebling.wav", 0
toomuch BYTE "toomuch.wav", 0

;; GLOBAL VARIABLES FOR CHECKING IF YOU LOST
lost DWORD 0
flag DWORD 0



.CODE

;;INITIALIZING DRAKE
drakesprite SPRITE <100, 100>




ClearScreen PROC uses ebx edx
    mov eax, 0
    mov ebx, 0
    mov edx, ScreenBitsPtr
    jmp L3
L1:
    mov BYTE PTR [edx + eax], 0
    inc eax
L2:
    cmp eax, 640
    jl L1
L3:
    inc ebx
    xor eax, eax    
    add edx, 640    
    cmp ebx, 480     
    jl L1

      ret
ClearScreen ENDP


;; *******************************************
;; MOVINGDRAKE 
;; *******************************************

;; Moving Drake with arrow keys

MovingDrake PROC

        ;; moving Drake Sprite
        mov ebx, KeyPress
        mov ecx, VK_DOWN
        cmp ebx, ecx                             
        jne UP
        INVOKE ClearScreen
        add ypos, 10
        INVOKE BasicBlit, offset drake_face_small, xpos, ypos
        INVOKE BasicBlit, offset meek, 400, 100


UP:
        mov ebx, KeyPress
        mov ecx, VK_UP
        cmp ebx, ecx
        jne RIGHT
        INVOKE ClearScreen
        sub ypos, 10
        INVOKE BasicBlit, offset drake_face_small, xpos, ypos
        INVOKE BasicBlit, offset meek, 400, 100


RIGHT:
        mov ebx, KeyPress
        mov ecx, VK_RIGHT
        cmp ebx, ecx
        jne LEFT
        INVOKE ClearScreen
        add xpos, 10
        INVOKE BasicBlit, offset drake_face_small, xpos, ypos
        INVOKE BasicBlit, offset meek, 400, 100


LEFT:
        mov ebx, KeyDown
        mov ecx, VK_LEFT
        cmp ebx, ecx
        jne theend
        INVOKE ClearScreen
        sub xpos, 10
        INVOKE BasicBlit, offset drake_face_small, xpos, ypos
        INVOKE BasicBlit, offset meek, 400, 100


theend:
        ret

MovingDrake ENDP





;; *******************************************
;; MOVINGMEEK
;; *******************************************
;; Moving Meek with mouse

MovingMeek PROC
    ;; moving him with the mouse


        mov edi, OFFSET MouseStatus
        mov ebx, (MouseInfo PTR [edi]).horiz
        mov xpos_meek, ebx
        mov ecx, (MouseInfo PTR [edi]).vert
        mov ypos_meek, ecx

        INVOKE ClearScreen
        INVOKE BasicBlit, offset drake_face_small, xpos, ypos
        INVOKE BasicBlit, offset meek, xpos_meek, ypos_meek
        INVOKE BasicBlit, OFFSET nicki, xpos_nicki, ypos_nicki

endmovingmeek:
    ret
    
MovingMeek ENDP


;; ****************************************************************
;; CHECKCOLLISION
;; ****************************************************************

;; Checks if Drake or Meek sprite collides with Nicki 

CheckCollision PROC 
    LOCAL top: DWORD, bottom: DWORD, left: DWORD, right: DWORD, temp: DWORD
;;mov esi, OFFSET drakesprite

        mov edi, OFFSET drakerect 
        mov esi, OFFSET drake_face_small
        mov ebx, (EECS205BITMAP PTR [esi]).dwWidth ;; width
        shr ebx, 1        ;; dividing by 2
        mov ecx, (EECS205BITMAP PTR [esi]).dwHeight ;; height
        shr ecx, 1        ;; dividing by 2

        mov temp, ebx
        mov eax, xpos
        add temp, eax
        mov eax, temp   ;; now right is in eax

        mov (EECS205RECT PTR [edi]).dwRight, eax

        mov temp, ebx
        mov eax, xpos
        sub temp, eax
        mov eax, temp   ;; now left is in eax

        mov (EECS205RECT PTR [edi]).dwLeft, eax

        mov temp, ecx
        mov eax, ypos
        add temp, eax
        mov eax, temp   ;; now bottom is in eax

        mov (EECS205RECT PTR [edi]).dwBottom, eax

        mov temp, ecx
        mov eax, ypos
        sub temp, eax
        mov eax, temp   ;; now top is in eax

        mov (EECS205RECT PTR [edi]).dwTop, eax
        
        INVOKE CheckIntersectRect, OFFSET drakerect, OFFSET recttest
        cmp eax, 1
        jne checkmeek
        ;INVOKE BasicBlit, offset meek, 400, 350
        mov eax, 1
        jmp returncollision

checkmeek:

        mov edi, OFFSET meekrect 
        mov esi, OFFSET meek
        mov ebx, (EECS205BITMAP PTR [esi]).dwWidth ;; width
        shr ebx, 1        ;; dividing by 2
        mov ecx, (EECS205BITMAP PTR [esi]).dwHeight ;; height
        shr ecx, 1        ;; dividing by 2

        mov temp, ebx
        mov eax, xpos_meek
        add temp, eax
        mov eax, temp   ;; now right is in eax

        mov (EECS205RECT PTR [edi]).dwRight, eax

        mov temp, ebx
        mov eax, xpos_meek
        sub temp, eax
        mov eax, temp   ;; now left is in eax

        mov (EECS205RECT PTR [edi]).dwLeft, eax

        mov temp, ecx
        mov eax, ypos_meek
        add temp, eax
        mov eax, temp   ;; now bottom is in eax

        mov (EECS205RECT PTR [edi]).dwBottom, eax

        mov temp, ecx
        mov eax, ypos_meek
        sub temp, eax
        mov eax, temp   ;; now top is in eax

        mov (EECS205RECT PTR [edi]).dwTop, eax
        
        INVOKE CheckIntersectRect, OFFSET meekrect, OFFSET recttest
        cmp eax, 1
        jne nocollision
        ;INVOKE BasicBlit, offset meek, 400, 350
        mov eax, 1
        jmp returncollision
             
nocollision:
        mov eax, 0              ;; RETURNS 1 IF COLLISION, 0 FOR NO COLLISION

returncollision:
        ret
CheckCollision ENDP



;; ****************************************************************
;; RESTARTCHECK
;; ****************************************************************

;; If lost, checking to see if user presses spacebar, so it can restart

RestartCheck PROC

        mov ebx, KeyPress
        mov ecx, VK_SPACE
        cmp ebx, ecx
        jne end_restartcheck
        mov flag, 0
        mov lost, 0
        mov xpos, 100
        mov ypos, 100
        INVOKE ClearScreen
        INVOKE BasicBlit, offset drake_face_small, xpos, ypos
        INVOKE BasicBlit, offset meek, 400, 100
        INVOKE PlaySound, OFFSET hotlinebling, 0, SND_FILENAME OR SND_ASYNC

end_restartcheck:
        ret

RestartCheck ENDP



;; ****************************************************************
;; GAMEINIT
;; ****************************************************************

GameInit PROC
         LOCAL top: DWORD, bottom: DWORD, left: DWORD, right: DWORD, temp: DWORD

        

        mov esi, OFFSET drakesprite
        mov ebx, (SPRITE PTR [esi]).xcenter
        mov ecx, (SPRITE PTR [esi]).ycenter
        mov xpos, ebx
        mov ypos, ecx
        INVOKE BasicBlit, OFFSET drake_face_small, xpos, ypos
        INVOKE BasicBlit, OFFSET nicki, xpos_nicki, ypos_nicki

        INVOKE PlaySound, OFFSET hotlinebling, 0, SND_FILENAME OR SND_ASYNC ;; play Hotline Bling from the getgo

        ;; NICKI RECT
        mov edi, OFFSET nickirect 
        mov esi, OFFSET nicki
        mov ebx, (EECS205BITMAP PTR [esi]).dwWidth ;; width
        shr ebx, 1        ;; dividing by 2
        mov ecx, (EECS205BITMAP PTR [esi]).dwHeight ;; height
        shr ecx, 1        ;; dividing by 2

        mov temp, ebx
        mov eax, xpos_nicki
        add temp, eax
        mov eax, temp   ;; now right is in eax

        mov (EECS205RECT PTR [edi]).dwRight, eax

        mov temp, ebx
        mov eax, xpos_nicki
        sub temp, eax
        mov eax, temp   ;; now left is in eax

        mov (EECS205RECT PTR [edi]).dwLeft, eax

        mov temp, ecx
        mov eax, ypos_nicki
        add temp, eax
        mov eax, temp   ;; now bottom is in eax

        mov (EECS205RECT PTR [edi]).dwBottom, eax

        mov temp, ecx
        mov eax, ypos_nicki
        sub temp, eax
        mov eax, temp   ;; now top is in eax

        mov (EECS205RECT PTR [edi]).dwTop, eax



	ret         ;; Do not delete this line!!!
GameInit ENDP


;; ****************************************************************
;; GAMEPLAY
;; ****************************************************************
GamePlay PROC
        

        INVOKE RestartCheck 
        mov eax, lost
        cmp eax, 1          ;; this compare is here so that it plays "Too Much" and displays text only once
        je endgameplay

        INVOKE MovingDrake
        INVOKE MovingMeek
        INVOKE CheckCollision
        cmp eax, 1
        jne endgameplay
        mov ebx, flag ;; 
        cmp ebx, 1
        je endgameplay
        mov flag, 1
        mov lost, 1
        INVOKE PlaySound, OFFSET toomuch, 0, SND_FILENAME OR SND_ASYNC 
        INVOKE DrawStr, OFFSET whatStr, 280, 200, 0ffh
        INVOKE DrawStr, OFFSET restartstr, 170, 220, 0ffh
        ;INVOKE DrawStr, 0FFSET toomuchstr, 150, 240, 0ffh
      
endgameplay:

	ret         ;; Do not delete this line!!!
GamePlay ENDP
	

END
