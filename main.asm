.model small
.stack 100h

; TODO: 4.add BALL physics.  5. check for collision ball with paddle and boundaries 6.  add score.
.data
	leftPadY dw 80
	leftPadX dw 10
	paddleWidth dw 07h
	paddleHeight dw 35
	rightPadY dw 80
	rightPadX dw 300
	
	topBoundary dw 10
	downBoundary dw 160
	velocity_y dw 20

	ballHeight dw 5
	ballWidth dw 5
	
	ballX dw 155
	ballY dw 80



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


ballXVal equ [bp + 4]
ballYVal equ [bp+6]
drawBall proc
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	
	mov cx, ballXVal ; X 
	mov dx, ballYVal ; Y
	
	draw_ball_left_horizontal:
		mov ah, 0Ch
		mov al, 0Fh
		mov bh, 00h
		int 10h
		
		inc cx
		mov ax, cx
		sub ax, ballXVal
		cmp ax, ballWidth
		jng draw_ball_left_horizontal
		
		mov cx, ballXVal
		inc dx
		mov ax, dx
		sub ax, ballYVal
		cmp ax, ballHeight
		jng draw_ball_left_horizontal

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 4
drawBall endp


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
	je move_up_check_left
	cmp al, 's'
	je move_down_check_left
	jmp ending
	move_up_check_left:
		mov dx, [topBoundary]
		cmp [leftPadY], dx
		jg move_up_left
		jmp ending
	move_up_left:
		mov cx, [velocity_y]
		sub [leftPadY], cx
		jmp ending
		
	move_down_check_left:
		mov dx, [downBoundary]
		cmp [leftPadY], dx
		jl move_down_left 
		jmp ending
	move_down_left:
		mov cx, [velocity_y]
		add [leftPadY], cx

		jmp ending

	ending:
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
	cmp al, 'o'     
	je move_up_check_right
	cmp al, 'l'     
	je move_down_check_right
	jmp ending2
	move_up_check_right:
		mov dx, [topBoundary]
		cmp [rightPadY], dx
		jg move_up_right
		jmp ending2
	move_up_right:
		mov cx, [velocity_y]
		sub [rightPadY], cx
		jmp ending2
	move_down_check_right:
		mov dx, [downBoundary]
		cmp [rightPadY], dx
		jl move_down_right
		jmp ending2
	move_down_right:
		mov cx, [velocity_y]
		add [rightPadY], cx
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
	push [ballY]
	push [ballX]
	call drawBall
	start_loop:	
		push [rightPadY]
		push [rightPadX]
		call drawPaddle
		push [leftPadY]
		push [leftPadX]
		call drawPaddle

		call checkExit
		call checkPaddleLeftMove
		call checkPaddleRightMove
		call clearScreenGraphics

		
		jmp start_loop
		
main endp 

end main
