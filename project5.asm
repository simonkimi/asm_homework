assume cs: code, ss: stack, ds: data

add_num_to_NUM MACRO
	               push bx
	               push dx
	               mov  ax, NUM[0]
	               mov  bx, 2
	               mul  bx
	               mov  bx, ax
	               pop  dx
	               mov  NUM[bx + 2], dx
	               dec  cx
	               inc  NUM[0]
	               pop  bx
	               inc  bx
ENDM


data segment
	NUM  dw 255 dup(0)
	IBUF db 255, 0, 255 dup(0)
	OBUF db 255 dup(0)
data ends

stack segment
	      dw 255 dup(0)
stack ends

code segment



input_num proc near                          		; 解析输入的数字, 将数据保存到NUM
	              mov            dx, offset IBUF 	; 输入字符串, 字符串应该在offset IBUF + 2
	              mov            ah, 10
	              int            21h
	              mov            ax, 0
	              mov            NUM[0], ax      	; 现在有0个数字
	              mov            bx, 0           	; 当前解析到第几个数字
	              mov            cl, IBUF[1]     	; cx为循环次数
	              mov            ch, 0
	parse_num:                                   	; 开始解析数字
	              mov            dx, 0           	; dx作为数字暂存地方

	parse_chr:    
	              mov            al, IBUF[bx + 2]
	              cmp            al, 32          	; 判断按键, 跳转到对应功能
	              je             is_space        	; 为空格键
	              cmp            al, 13
	              je             input_num_end   	; 为回车键
	              mov            ah, 0           	; 将ascii转换成数字
	              sub            ax, 48
	              push           bx              	; ds = ds * 10 + ax
	              push           ax
	              mov            ax, dx
	              mov            bx, 10
	              mul            bx
	              mov            dx, ax
	              pop            ax
	              add            dx, ax
	              pop            bx
	              inc            bx              	; 解析下一个数字
	              loop           parse_chr
	              jmp            input_num_end
    

	is_space:     
	              add_num_to_NUM
	              jmp            parse_num
    


	input_num_end:
	              add_num_to_NUM
	              ret
input_num endp




start proc near
    
	              mov            ax, data        	; 初始化data和stack
	              mov            ds, ax
	              mov            ax, stack
	              mov            ss, ax
	              mov            sp, 240

	              call           input_num       	; 测试程序
	              int            3
	              mov            ax, 4c00h       	; 退出程序
	              int            21h
start endp


code ends
end start