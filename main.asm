.model small
.stack 100h

; TODO: 3. make it mode 4. draw a ball and add physics.  5. draw and move another paddle.  add score.
.data
	leftPadY dw 80
	leftPadX dw 10
	paddleWidth dw 07h
	paddleHeight dw 30
	rightPadY dw 80
	rightPadX dw 280
	
	topBoundary dw 10
	downBoundary dw 310
	velocity_y dw 20

	



.code 

setGraphic proc 
	push ax
	mov ax, 13h
	int 10h
	pop ax
	ret
setGraphic endp


x equ [bp+4]
y equ [bp+6]
drawPaddle proc
	push bp
	mov bp, sp

	push dx
	push cx
	push bx 
	push ax
	
	
	mov cx, x ; X 
	mov dx, y ; Y
	
	draw_paddle_left_horizontal:
		mov ah, 0Ch
		mov al, 0Fh
		mov bh, 00h
		int 10h
		
		inc cx
		mov ax, cx
		sub ax, x
		cmp ax, paddleWidth
		jng draw_paddle_left_horizontal
		
		mov cx, x
		inc dx
		mov ax, dx
		sub ax, y
		cmp ax, paddleHeight
		jng draw_paddle_left_horizontal
	pop bp
	pop ax
	pop bx
	pop cx
	pop dx
	ret 4
drawPaddle endp

clearScreenGraphics proc
	push ax
    mov ax, 0A000h     
    mov es, ax
    xor di, di         
    mov al, 0          
    mov cx, 64000      
    cld                
    rep stosb          
	pop ax
    ret
clearScreenGraphics endp





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

checkPaddleLeftMove proc
	push ax
	push dx
	push cx
	
	mov ah, 00h
	int 16h
	cmp al, 'w'
	je move_up_check1
	cmp al, 's'
	je move_down_check1
	
	move_up_check1:
		mov dx, [topBoundary]
		cmp [leftPadY], dx
		jg move_up1
		jmp ending1
	move_up1:
		mov cx, [velocity_y]
		sub [leftPadY], cx
		call clearScreenGraphics
		push [leftPadY]
		push [leftPadX]
		call drawPaddle
		push [rightPadY]
		push [rightPadX]
		call drawPaddle

		jmp ending1
	move_down_check1:
		mov dx, [downBoundary]
		cmp [leftPadY], dx
		jl move_down1 
		jmp ending1
	move_down1:
		mov cx, [velocity_y]
		add [leftPadY], cx
		call clearScreenGraphics
		push [leftPadY]
		push [leftPadX]
		call drawPaddle
		push [rightPadY]
		push [rightPadX]
		call drawPaddle

		jmp ending1

	ending1:
		pop cx
		pop dx
		pop ax
		ret
checkPaddleLeftMove endp

checkPaddleRightMove proc
	push ax
	push dx
	push cx
	
	mov ah, 00h
	int 16h
	cmp al, 'i'
	je move_up_check2
	cmp al, 'k'
	je move_down_check2
	
	move_up_check2:
		mov dx, [topBoundary]
		cmp [rightPadY], dx
		jg move_up2
		jmp ending2
	move_up2:
		mov cx, [velocity_y]
		sub [rightPadY], cx
		call clearScreenGraphics
		push [rightPadY]
		push [rightPadX]
		call drawPaddle
		push [leftPadY]
		push [leftPadX]
		call drawPaddle

		jmp ending2
	move_down_check2:
		mov dx, [downBoundary]
		cmp [rightPadY], dx
		jl move_down2
		jmp ending2
	move_down2:
		mov cx, [velocity_y]
		add [rightPadY], cx
		call clearScreenGraphics
		push [rightPadY]
		push [rightPadX]
		call drawPaddle
		push [leftPadY]
		push [leftPadX]
		call drawPaddle

		jmp ending2

	ending2:
		pop cx
		pop dx
		pop ax
		ret
checkPaddleRightMove endp

main proc 

	mov ax, @data
	mov ds, ax
	
	call setGraphic
	push [leftPadY]
	push [leftPadX]
	call drawPaddle
		
	push [rightPadY]
	push [rightPadX]
	call drawPaddle


	start_loop:	
		
		call checkExit
		call checkPaddleLeftMove
		call checkPaddleRightMove

		
		jmp start_loop
		
main endp 

end main
