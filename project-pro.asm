include macro.lib
assume cs: code, ss: stack, ds: data

data segment
	KM     dw 0
	ISRUN  db 0
	PAR    db 32 dup(0)
	PARB   dw 32 dup(0)
	TMP    db 32 dup(0)
	LED    db 0C0H, 0F9H, 0A4H, 0B0H, 99H, 92H, 82H, 0F8H, 80H, 90H
	LED_M1 db 0
	LED_M2 db 0
data ends

stack segment
	      db 128 dup(0)
stack ends


code segment
	M55_P      equ              1100110B        	; 6521
	M55_CON    equ              10010000B       	; 全方式0, A入
	M55_A      equ              1100000B        	; 65
	M55_B      equ              1100010B        	; 651
	M55_C      equ              1100100B        	; 652

	M53_P      equ              1101111000B     	; 986543
	M53_CON    equ              00110001B       	; 计数器0, 16位, 方式0, 10进制
	M53_0      equ              1111000B        	; 6543

	M244_P     equ              1101000B        	; 653


reset proc                                  		; 重置8253
	           post             M53_P, M53_CON
	           post             M53_0, 0
	           post             M53_0, 01h
	           ret
reset endp


check_run proc                              		; 检测所有
	           register_protect
	           get              M55_A
	           mov              ah, al

	           and              al, 1B
	           cmp              al, 0           	; 8253计数完成
	           je               btn

	           inc              KM[0]
	           call             reset
	btn:       
	           and              ah, 10B
	           cmp              ah, 0           	; 按钮被按下
	           jne              c_e

	           call             reset
	           mov              KM[0], 0
	           mov              ISRUN[0], 0
	           call             wait_btn
	c_e:       
	           register_recover
	           ret
check_run endp

check_stop proc                             		; 停止计数时等待按钮被按下
	           register_protect
	           get              M55_A
	           and              al, 10B
	           cmp              al, 0
	           jne              s_e

	           mov              ISRUN[0], 1
	           mov              KM[0], 0
	           call             wait_btn        	; 等待按钮弹起
	s_e:       
	           register_recover
	           ret
check_stop endp


wait_btn proc                               		; 等待按钮弹起并刷新LED
	           register_protect
	w:         
	           call             show_km
	           call             show_pri
	           get              M55_A
	           and              al, 10B
	           cmp              al, 0
	           je               w
	           register_recover
	           ret
wait_btn endp



show_led proc                               		; 显示ax数字, PAR[0]开始偏移, PAR[1]结束偏移, PAR[2]加小数点偏移
	           register_protect
	           mov              bx, 0
	           mov              cl, PAR[0]
	           jmp              start_led
	next_led:  
	           shr              cl, 1
	start_led: 
	           post             M55_C, cl

	           mov              bl, 10
	           div              bl              	; al为商, ah为余数

	           mov              bl, ah
	           mov              bl, LED[bx]
	           cmp              cl, PAR[2]
	           jne              dot
	           and              bl, 01111111B
	dot:       

	           post             M55_B, bl
	           sleep            1000
	           mov              ah, 0

	           cmp              cl, PAR[1]
	           jne              next_led
	           register_recover
	           ret
show_led endp


show_km proc                                		; 显示千米数
	           mov              PAR[0], 10B
	           mov              PAR[1], 1B
	           mov              PAR[2], 10B
	           mov              ax, KM[0]
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


show_pri proc                               		; 显示金额
	           mov              ax, KM[0]       	; 公里数
	           cmp              ax, 0
	           jne              not_zero
	           mov              dx, 0
	           jmp              less_2
	not_zero:  
	           mov              bl, 10
	           div              bl              	; al为公里数, ah为余数
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
	           mov              PAR[0], 1000000B
	           mov              PAR[1], 10000B
	           mov              PAR[2], 100000B
	           mov              ax, dx
	           call             show_led
	           ret
show_pri endp



main proc
	           mov              ax, stack
	           mov              ss, ax
	           mov              sp, 128
            
	           mov              ax, data
	           mov              ds, ax
        
	           post             M55_P, M55_CON  	; 初始化8255
	           call             reset
	start:     
	           call             show_km
	           call             show_pri

	           mov              al, ISRUN[0]    	; 判断当前是否咋运行
	           cmp              al, 0
	           je               stop
	run:       
	           call             check_run
	           jmp              start

	stop:      
	           call             check_stop
	           jmp              start
            
	           mov              ax, 4c00h
	           int              21h
main endp
code ends
end main