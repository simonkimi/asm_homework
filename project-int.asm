include macro.lib
assume cs: code, ss: stack, ds: data

data segment
	KM     dw 0
	STATE  db 0                                                                     	; 0: 停止, 1: 运行, 2: 暂停
	PAR    db 3 dup(0)
	LED    db 0C0H, 0F9H, 0A4H, 0B0H, 099H, 092H, 082H, 0F8H, 080H, 090H, 0BFH, 0CFH
	LED_M2 db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 02AH, 033H
data ends

stack segment
	      db 128 dup(0)
stack ends


code segment
	M55_P       equ              1100110B                        	; 6521
	M55_CON     equ              10000000B                       	; 全方式0, A入
	M55_A       equ              1100000B                        	; 65
	M55_B       equ              1100010B                        	; 651
	M55_C       equ              1100100B                        	; 652

	M53_P       equ              1101111000B                     	; 986543
	M53_CON     equ              00110001B                       	; 计数器0, 16位, 方式0, 10进制
	M53_0       equ              1111000B                        	; 6543

	M8259_P     equ              10001101000B                    	; 10, 653
	M8259_CP    equ              1101000B                        	; 653


	M244_P      equ              1101000B                        	; 653

reset proc                                                   		; 重置8253
	            post             M53_P, M53_CON
	            post             M53_0, 0
	            post             M53_0, 01h
	            ret
reset endp


btn proc far
	            inc              STATE
	            cmp              STATE, 3
	            jne              btn_exit

	            mov              KM, 0
	            mov              STATE, 0
	btn_exit:   
	            call             reset
	            iret
btn endp


plus proc far
	            cmp              STATE, 1
	            jne              plus_exit
	            inc              KM
	            call             reset
	plus_exit:  
	            iret
plus endp


show_led proc                                                		; 显示ax数字, PAR[0]开始偏移, PAR[1]结束偏移, PAR[2]加小数点偏移
	            register_protect
	            mov              bx, 0
	            mov              cl, PAR[0]
	            jmp              start_led
	next_led:   
	            shr              cl, 1
	start_led:  
	            post             M55_C, cl

	            mov              bl, 10
	            div              bl                              	; al为商, ah为余数

	            mov              bl, ah
	            mov              bl, LED[bx]
	            cmp              cl, PAR[2]                      	; 最高位价格都好
	            jne              dot
	            and              bl, 01111111B
	dot:        
	            post             M55_B, bl
	            mov              bl, ah
	            mov              bl, LED_M2[bx]
	            post             M55_A, bl
	            sleep            1000
	            mov              ah, 0

	            cmp              cl, PAR[1]
	            jne              next_led
	            register_recover
	            ret
show_led endp


show_chr proc                                                		; ax放偏移, PAR[0]为C偏移
	            register_protect
	            post             M55_C, PAR[0]

	            mov              bx, ax
	            mov              bl , LED[bx]

	            post             M55_B, bl

	            mov              bx, ax
	            mov              bl, LED_M2[bx]
	        
	            post             M55_A, bl
	    
	            sleep            1000
	            register_recover
	            ret
show_chr endp


show_km proc                                                 		; 显示千米数
	            mov              PAR[0], 10B
	            mov              PAR[1], 1B
	            mov              PAR[2], 10B
	            mov              ax, KM
	            mov              bl, 10
	            div              bl
	            mov              bl, ah
	            mov              ah, 0
	            call             show_led

	            mov              PAR[0], 100B
	            mov              PAR[1], 100B
	            mov              al, bl
	            mov              ah, 0
	            call             show_led

	            ret
show_km endp


show_pri proc                                                		; 显示金额
	            mov              ax, KM                          	; 公里数
	            cmp              ax, 0
	            jne              not_zero
	            mov              dx, 0
	            jmp              less_2
	not_zero:   
	            mov              bl, 10
	            div              bl                              	; al为公里数, ah为余数
	            cmp              ah, 0
	            je               inc_km
	            inc              al
	inc_km:     
	            mov              dx, 60

	            cmp              al, 2
	            jle              less_2
	            sub              al, 2

	            cmp              al, 18
	            jle              less_20
	            add              dx, 180
	            sub              al, 18
	            mov              bl, 15
	            mul              bl
	            add              dx, ax
	            jmp              less_2
	
	less_20:    
	            mov              bl, 10
	            mul              bl
	            add              dx, ax
	less_2:     
	            mov              PAR[0], 10000000B
	            mov              PAR[1], 100000B
	            mov              PAR[2], 1000000B
	            mov              ax, dx
	            call             show_led
	            ret
show_pri endp


show_helper proc                                             		; 显示特殊符号
	            register_protect
	            mov              PAR[0], 10000B
	            mov              ax, 10
	            call             show_chr

	            mov              PAR[0], 1000B
	            mov              ax, 11
	            call             show_chr
	            register_recover
	            ret
show_helper endp




main proc
	            mov              ax, stack                       	; 初始化程序
	            mov              ss, ax
	            mov              sp, 128
	            mov              ax, data
	            mov              ds, ax

	            mov              ax, 0                           	; 装载中断程序
	            mov              es, ax

	            mov              word ptr es: [32*4], offset btn 	; IR0 32号中断
	            mov              word ptr es: [32*4+2], seg btn

	            mov              word ptr es: [34*4], offset plus	; IR2 34号中断
	            mov              word ptr es: [34*4+2], seg plus

	            post             M55_P, M55_CON                  	; 初始化8255

	            cli
	            post             M8259_CP, 10011B                	; 初始化8259
	            post             M8259_P, 32                     	; 32号~40号中断
	            post             M8259_P, 1111B
	            post             M8259_P, 11111010B              	; 开启2号和0号中断
	            sti

	            call             reset                           	; 初始化8253
	start:      
	            call             show_pri
	            call             show_km
	            call             show_helper

	            jmp              start
	            mov              ax, 4c00h
	            int              21h
main endp
code ends
end main