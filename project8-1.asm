assume cs: code

code segment
	M8255_INIT_PORT equ  1100110B           	; 6521
	M8255_INIT      equ  10000010B          	; 全方式0, B输入其他输出
	M8255_ADC_A     equ  1100000B           	; 65
	M8255_ADC_B     equ  1100010B           	; 65
	M8255_ADC_C     equ  1100100B           	; 652
	M8255_W_7       equ  10000000B          	; 7
	M8255_W_0       equ  0                  	; 0
	
main proc
	start:          
	                mov  ax, 0
	                mov  ds, ax
	                mov  bx, 0
	                mov  dx, M8255_INIT_PORT	; 初始化8255
	                mov  al, M8255_INIT
	                out  dx, al
	          
	                mov  dx, M8255_ADC_A    	; 0808复位
	                mov  al, M8255_W_7
	                out  dx, al

	                mov  cx, 0FFh           	; 延迟一段时间
	                loop $

	                mov  dx, M8255_ADC_A    	; 0808启动
	                mov  al, M8255_W_0
	                out  dx, al

	                mov  cx, 0FFh           	; 延迟一段时间
	                loop $

	                mov  dx, M8255_ADC_C    	; PC7 = 1
	                mov  al, M8255_W_7
	                out  dx, al

	                mov  dx, M8255_ADC_B    	; al = PB
	                in   al, dx
	                mov  [bx], al

	                jmp  start
	                mov  ax, 4c00h
	                int  21h
main endp

    
code ends
end main