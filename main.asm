.model small
.stack 100h

; TODO: 1. open a graphics screen, 2. draw paddle, 3. make it mode 4. draw a ball and add physics.  5. draw and move another paddle.  add score.
.data
	leftPadY dw 120
	leftPadX dw 30



.code 

setGraphic proc 
	push ax
	mov ax, 13h
	int 10h
	pop ax
	ret
setGraphic endp

drawPixel proc
	push bp
	push dx
	push cx
	push bx 
	push ax
	mov bp, sp
	mov     dx, [leftPadY]  ; y value  
	mov     cx, [leftPadX]  ; x value 
	mov     bh, 0      
	mov     ax, 0C02h  
	int     10h
	pop bp
	pop ax
	pop bx
	pop cx
	pop dx
	ret
drawPixel endp

clear_screen proc
	push ax
	mov ah,00h 						
	mov al,13h 						
	int 10h							

	mov ah,0Bh						
	mov bh,00h						
	mov bl,00h 						
	int 10h
	pop ax
	ret
clear_screen endp



textModeExit proc
	push ax
	mov ax, 3
	int 10h
	mov ax,4C00h 		
	int 21h
	pop ax
	ret
textModeExit endp


checkExit proc
	push ax
	mov ah, 00h 
	int 16h 
	cmp al, 1Bh
	je textModeExit
	pop ax
	ret
checkExit endp


main proc 

	mov ax, @data
	mov ds, ax
	
	call setGraphic
	;call drawPaddle
	
	start_loop:	
		call drawPixel

		call checkExit
		;call clear_screen
		jmp start_loop
		
main endp 

end main
