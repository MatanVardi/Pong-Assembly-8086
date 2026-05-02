.model small
.stack 100h

.data
	leftPadY dw 80
	leftPadX dw 10
	paddleWidth dw 07h
	paddleHeight dw 35
	rightPadY dw 80
	rightPadX dw 300
	
	topBoundary dw 10
	downBoundary dw 160
	downBoundaryCollision dw 180
	topBoundaryCollision dw 5
	rightBoundary dw 300
	leftBoundary dw 10
	velocityY dw 20

	ballHeight dw 5
	ballWidth dw 5
	
	ballX dw 155
	ballY dw 80

	ballVelocityX dw 3
	ballVelocityY dw 4
	
	;Will result in either 1 or 2 for the direction
	;(can be right direction for the x and the y would either be 1 which is down and we use add or 2 for sub
	; 1 - is left or down and 2 is right or up
	ballDirX db 1
	ballDirY db 1
	

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

moveBallRightUp proc
	push ax
	push dx
	mov ax, [ballVelocityX]
	add [ballX], ax
	mov dx, [ballVelocityY]
	sub [ballY], dx
	pop dx
	pop ax
	ret
moveBallRightUp endp

moveBallRightDown proc
	push ax
	push dx
	mov ax, [ballVelocityX]
	add [ballX], ax
	mov dx, [ballVelocityY]
	add [ballY], dx
	pop dx
	pop ax
	ret
moveBallRightDown endp

moveBallLeftUp proc
	push ax
	push dx
	mov ax, [ballVelocityX]
	sub [ballX], ax
	mov dx, [ballVelocityY]
	sub [ballY], dx
	pop dx
	pop ax
	ret
moveBallLeftUp endp

moveBallLeftDown proc
	push ax
	push dx
	mov ax, [ballVelocityX]
	sub [ballX], ax
	mov dx, [ballVelocityY]
	add [ballY], dx
	pop dx
	pop ax
	ret
moveBallLeftDown endp

randomizeDirections proc
    push ax
    push cx
    
    mov ah, 00h
    int 1Ah         
    
    mov al, dl      
    shr al, 2      
    and al, 01h
    inc al         
    mov [ballDirX], al
    
    mov al, dl
    shr al, 4       
    and al, 01h
    inc al         
    mov [ballDirY], al
    
    pop cx
    pop ax
    ret
randomizeDirections endp


moveBall proc
	cmp [ballDirX], 1
	je left_x_val
	jmp right_x_val
	
	left_x_val:
		cmp [ballDirY], 1
		je down_y_val
		jmp up_y_val
	
	down_y_val:
		call moveBallLeftDown
		jmp endingProc

	up_y_val:
		call moveBallLeftUp
		jmp endingProc

	right_x_val:
		cmp [ballDirY], 1
		je down_y_val_second
		jmp up_y_val_second
	
	down_y_val_second:
		call moveBallRightDown
		jmp endingProc
		
	up_y_val_second:
		call moveBallRightUp
		jmp endingProc

	endingProc:
		ret
moveBall endp



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
	jge BoundCollision
	cmp ax, [leftBoundary]
	jle BoundCollision
	jmp endProgram
	BoundCollision:
		mov [ballX], 155
		mov [ballY], 80
		call randomizeDirections
		jmp endProgram
		
	endProgram:
		pop ax
		ret 
ballCollisionVerticalBoundaries endp

ballCollisionHorizontalBoundaries proc
	push ax 
	
	mov ax, [ballY]
	cmp ax, [topBoundary]
	jle change_y_to_down
	cmp ax, [downBoundaryCollision]
	jge change_y_to_up
	jmp endBallCollisionProc
	
	change_y_to_down:
	mov [ballDirY], 1
	add [ballY], 1
	jmp endBallCollisionProc

	change_y_to_up:
	mov [ballDirY], 2
	sub [ballY], 1
	jmp endBallCollisionProc
	
	endBallCollisionProc:
	pop ax
	ret
ballCollisionHorizontalBoundaries endp

ballCollisionPaddleLeft proc
    push ax
    push dx
    push cx
    
    mov ax, [ballX]
    
    mov dx, [leftPadX]
    add dx, [paddleWidth]
    cmp ax, dx
    jg endCollisionProc    
    
    cmp ax, [leftPadX]
    jl endCollisionProc     

    mov cx, [ballY]
    
    cmp cx, [leftPadY]
    jl endCollisionProc     
    
    mov dx, [leftPadY]
    add dx, [paddleHeight]
    cmp cx, dx
    jg endCollisionProc     

    mov [ballDirX], 2     
    
endCollisionProc:
    pop cx
    pop dx
    pop ax
    ret
ballCollisionPaddleLeft endp

ballCollisionPaddleRight proc
    push ax
    push dx
    push cx

    mov ax, [ballX]
    add ax, [ballWidth]     

    cmp ax, [rightPadX]
    jl endCollisionRightProc    

    mov dx, [rightPadX]
    add dx, [paddleWidth]
    cmp ax, dx
    jg endCollisionRightProc    

    mov cx, [ballY]

    cmp cx, [rightPadY]
    jl endCollisionRightProc    

    mov dx, [rightPadY]
    add dx, [paddleHeight]
    cmp cx, dx
    jg endCollisionRightProc   

    mov [ballDirX], 1  
	

endCollisionRightProc:
    pop cx
    pop dx
    pop ax
    ret
ballCollisionPaddleRight endp



main proc 
	mov ax, @data
	mov ds, ax
	
	call setGraphic
	call randomizeDirections
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

		call ballCollisionVerticalBoundaries
		call ballCollisionHorizontalBoundaries
		call ballCollisionPaddleLeft
		call ballCollisionPaddleRight
		call moveBall

		call checkExit
		call checkPaddles

		call delay
		jmp game_loop
		
main endp 

end main
