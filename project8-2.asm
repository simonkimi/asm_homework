assume cs: code, ds: data, ss: stack

data segment
	SHOW  db 5 dup(0)
	SHOW2 dw 5 dup(0)
	LED   db 0C0H, 0F9H, 0A4H, 0B0H, 99H, 92H, 82H, 0F8H, 80H, 90H, 7fh
data ends

stack segment
	      db 32 dup(0)
stack ends


sleep macro t
	      push cx
	      mov  cx, t
	      loop $
	      pop  cx
endm



code segment

	M8255_INIT_PORT equ   1100110B           	; 6521
	M8255_INIT      equ   10000000B          	; 全方式0, A输入, 其他输出
	M8255_ADC_A     equ   1100000B           	; 65
	M8255_ADC_B     equ   1100010B           	; 651
	M8255_ADC_C     equ   1100100B           	; 652
	S_START         equ   1100000000B        	; 98


show_led proc
	                mov   al, SHOW
	                mov   ah, 0              	; ax为数据
	                mov   cx, 1B             	; cx为偏移量


	next_led:       
	                push  ax
	                mov   dx, M8255_ADC_C    	; 控制端显示
	                mov   al, cl
	                shl   cx, 1
	                out   dx, al
	                pop   ax
                    
	                mov   bl, 51             	; 计算数据区
	                div   bl                 	; 除51后, al为商, ah为余数
	                mov   bl, al
	                mov   bh, 0
	                mov   SHOW[1], al
	                mov   al, LED[bx]
	                cmp   cl, 10B
	                jne   dot
	                and   al, 01111111B      	; 最高位加个小数点
	dot:            
	                mov   dx, M8255_ADC_B
	                out   dx, al
	                sleep 1000
	                mov   bl, 10
	                mov   al, ah
	                mul   bl
	                cmp   cx, 1000B
	                jne   next_led
	                ret
show_led endp



main proc
	      
	                mov   ax, stack
	                mov   ss, ax
	                mov   sp, 32
	                mov   ax, data
	                mov   ds, ax
	                mov   bx, 0
	                mov   dx, M8255_INIT_PORT	; 初始化8255A
	                mov   al, M8255_INIT
	                out   dx, al
	start:          
	                mov   dx, S_START        	; 选择ADC0808
	                mov   al, 0
	                out   dx, al

	                mov   cx, 0FFh           	; 等待转换完毕
	                loop  $

	                mov   dx, S_START        	; 取出数据
	                in    al, dx
	                mov   SHOW, al

	                call  show_led

	                jmp   start
	                mov   ax, 4c00h
	                int   21h
main endp
code ends
end main