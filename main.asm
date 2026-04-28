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
	rightBoundary dw 300
	leftBoundary dw 10
	velocityY dw 20

	ballHeight dw 5
	ballWidth dw 5
	
	ballX dw 155
	ballY dw 80

	ballVelocityX dw 6
	ballVelocityY dw 3
	
	;Will result in either 1 or 2 for the direction
	;(can be right direction for the x and the y would either be 1 which is down and we use add or 2 for sub
	
	ballDirX dw 1
	ballDirY dw 1

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
	pop ax
	pop bx
	pop cx
	pop dx
	pop bp
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


moveBallRight proc
	push ax
	push dx
	mov ax, [ballVelocityX]
	add [ballX], ax
	mov dx, [ballVelocityY]
	add [ballY], dx
	pop dx
	pop ax
	ret
moveBallRight endp

moveBallLeft proc
	push ax
	push dx
	mov ax, [ballVelocityX]
	sub [ballX], ax
	mov dx, [ballVelocityY]
	add [ballY], dx
	pop dx
	pop ax
	ret
moveBallLeft endp


generateRandomNumAndMoveBall proc
	push ax
	mov ah, 00h
	int 1Ah
	mov al, dl
	and al, 01h
	inc al
	cmp al, 1
	je move_b_right
	cmp al, 2
	je move_b_left
	jmp end_proc
	move_b_right:
		call moveBallRight
		jmp end_proc
	move_b_left:
		call moveBallLeft
		jmp end_proc
	end_proc:
		pop ax
		ret
generateRandomNumAndMoveBall endp



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
    mov ah, 01h      
    int 16h
    jz exitDone          

    cmp al, 1Bh          
    jne exitDone         

    mov ah, 00h          
    int 16h
    call textModeExit    

exitDone:
    pop ax
    ret
checkExit endp

delay proc
    push ax
    push cx
    push dx
    mov ah, 86h
    mov cx, 0000h    
    mov dx, 8F45h    
    int 15h
    pop dx
    pop cx
    pop ax
    ret
delay endp


checkPaddles proc
	push ax
	push dx
	push cx
	
	mov ah, 01h
    int 16h
    jz ending 
	
    mov ah, 00h      
    int 16h
	cmp al, 'o'     
	je move_up_check_right
	cmp al, 'l'     
	je move_down_check_right
	
	cmp al, 'w'
	je move_up_check_left
	cmp al, 's'
	je move_down_check_left
	jmp ending

	
	move_up_check_right:
		mov dx, [topBoundary]
		cmp [rightPadY], dx
		jg move_up_right
		jmp ending
	move_up_right:
		mov cx, [velocityY]
		sub [rightPadY], cx
		jmp ending
	move_down_check_right:
		mov dx, [downBoundary]
		cmp [rightPadY], dx
		jl move_down_right
		jmp ending
	move_down_right:
		mov cx, [velocityY]
		add [rightPadY], cx
		jmp ending
		
		
	move_up_check_left:
		mov dx, [topBoundary]
		cmp [leftPadY], dx
		jg move_up_left
		jmp ending
	move_up_left:
		mov cx, [velocityY]
		sub [leftPadY], cx
		jmp ending
		
	move_down_check_left:
		mov dx, [downBoundary]
		cmp [leftPadY], dx
		jl move_down_left 
		jmp ending
	move_down_left:
		mov cx, [velocityY]
		add [leftPadY], cx


	ending:
		pop cx
		pop dx
		pop ax
		ret
checkPaddles endp

ballCollisionVerticalBoundaries proc
	push ax
	
	mov ax, [ballX]
	cmp ax, [rightBoundary]
	jge rightBoundCollision
	cmp ax, [leftBoundary]
	jle rightBoundCollision
	jmp endProgram
	rightBoundCollision:
		mov [ballX], 155
		mov [ballY], 80
		jmp endProgram
	endProgram:
		pop ax
		ret 
ballCollisionVerticalBoundaries endp



main proc 

	mov ax, @data
	mov ds, ax
	
	call setGraphic
	game_loop:	
		call clearScreenGraphics
		push [rightPadY]
		push [rightPadX]
		call drawPaddle
		push [leftPadY]
		push [leftPadX]
		call drawPaddle
		push [ballY]
		push [ballX]
		call drawBall
		;call generateRandomNumAndMoveBall

		call ballCollisionVerticalBoundaries

		call checkExit
		call checkPaddles

		call delay
		jmp game_loop
		
main endp 

end main
