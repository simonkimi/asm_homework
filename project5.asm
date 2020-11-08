include macro.lib

	               assume cs: code, ss: stack, ds: data


add_num_to_NUM macro                               		; 将数字存到NUM中, 同时NUM数字自增1
	               push   bx
	               push   dx
	               mov    ax, NUM[0]
	               mov    bx, 2
	               mul    bx
	               mov    bx, ax
	               pop    dx
	               mov    NUM[bx + 2], dx
	               dec    cx
	               inc    NUM[0]
	               pop    bx
	               inc    bx
endm




auth macro
	             push      cx
	             mov       cx, 3
	auth_start:  
	             call      input_num
	             cmp       NUM[2], 4155
	             je        auth_success
	             print_str STR_AUTH_FAUL
	             loop      auth_start
	             jmp       exit
	auth_success:
	             print_str STR_AUTH_SUCCESS
	             pop       cx
endm


data segment
	NUM              dw 255 dup(0)
	OBUF             db 255 dup(0)
	IBUF             db 255, 0, 255 dup(0)
	STR_LOGIN        db 0dh, 0ah,'plz enter your pwd:', 0dh, 0ah, '$'
	STR_AUTH_FAUL    db 0dh, 0ah,'sorry, but your pwd is not correct' , 0dh, 0ah, '$'
	STR_AUTH_SUCCESS db 0dh, 0ah,'Welcome, 201804134155!', 0dh, 0ah, '$'
	STR_MENU         db 'plz select function', 0dh, 0ah,'1: sort', 0dh, 0ah,'2: smooth', 0dh, 0ah,'$'
	STR_SORT         db 0dh, 0ah,'plz input numbers, split by space', 0dh, 0ah,'$'
	STR_EMPTY        db 255 dup(' '), 0dh, 0ah,'$'
data ends

stack segment
	      dw 255 dup(0)
stack ends

code segment



input_num proc near                              		; 解析输入的数字, 将数据保存到NUM
	               protect_register
	               input_str        IBUF
	               mov              ax, 0
	               mov              NUM[0], ax       	; 现在有0个数字
	               mov              bx, 0            	; 当前解析到第几个数字
	               mov              cl, IBUF[1]      	; cx为循环次数
	               mov              ch, 0
	parse_num:                                       	; 开始解析数字
	               mov              dx, 0            	; dx作为数字暂存地方
	parse_chr:     
	               mov              al, IBUF[bx + 2]
	               cmp              al, 32           	; 判断按键, 跳转到对应功能
	               je               is_space         	; 为空格键
	               cmp              al, 13
	               je               input_num_end    	; 为回车键
	               mov              ah, 0            	; 将ascii转换成数字
	               sub              ax, 48
	               push             bx               	; ds = ds * 10 + ax
	               push             ax
	               mov              ax, dx
	               mov              bx, 10
	               mul              bx
	               mov              dx, ax
	               pop              ax
	               add              dx, ax
	               pop              bx
	               inc              bx               	; 解析下一个数字
	               loop             parse_chr
	input_num_end:                                   	; 输入结束, 储存数字并结束运行
	               add_num_to_NUM
	               recover_register
	               ret
	is_space:      
	               add_num_to_NUM
	               jmp              parse_num
input_num endp




print_num proc near                              		; 打印一个数字, 数据存在ax中
	               protect_register
	               mov              cx, 1
	               jmp              first_num
	next_num:      
	               mov              dx, 0
	               inc              cx
	first_num:     
	               mov              dx, 0
	               mov              bx, 10
	               div              bx               	; ax为商, dx为余数
	               add              dx, 48
	               push             dx
	               cmp              ax, 0            	; 商为0,
	               jne              next_num
	               mov              bx, 0            	; bx用于计算OBUF的偏移量

	reverse:       
	               pop              dx
	               mov              OBUF[bx], dl
	               inc              bx
	               loop             reverse
	               mov              OBUF[bx + 1], 0dh
	               mov              OBUF[bx + 2], 0ah
	               mov              OBUF[bx + 3], '$'
	               print_str        OBUF
	               recover_register
	               ret


print_num endp


menu proc near
	               protect_register
	menu_start:    
	               print_str        STR_MENU
	               input_ascii
	               cmp              al, '1'
	               je               menu_sort
	               cmp              al, '2'
	               je               menu_smooth
	               jmp              menu_exit
	menu_sort:     
	               call             sort
	               jmp              menu_start

	menu_smooth:   
	
	menu_exit:     
	               recover_register
	               ret
menu endp


sort_num proc near                               		; 对数字进行排序, 约定数字放在NUM里, NUM[0]为个数, 后面的为数字
	               protect_register
	               mov              cx, NUM[0]
	               dec              cx
	sort_outer:    
	               mov              dx, cx
	               mov              bx, 0
	sort_inner:    
	               mov              ax, NUM[bx + 2]
	               cmp              ax, NUM[bx + 4]
	               jb               chg_finish
	               xchg             ax, NUM[bx + 4]
	               mov              NUM[bx + 2], ax
	chg_finish:    
	               add              bx, 2
	               dec              dx
	               cmp              dx, 0
	               jne              sort_inner
	               loop             sort_outer
	               recover_register
	               ret
sort_num endp


print_num_list proc near
	               protect_register
	               mov              cx, NUM[0]
	               mov              bx, 0
	num_start:     
	               mov              ax, NUM[bx + 2]
	               call             print_num
	               add              bx, 2
	               loop             num_start
	               recover_register
	               ret
print_num_list endp


sort proc near
	               protect_register
	               print_str        STR_SORT
	               call             input_num
	               call             sort_num
	               print_str        STR_EMPTY
	               call             print_num_list
	               recover_register
	               ret
sort endp




start proc near
    
	               mov              ax, data         	; 初始化data和stack
	               mov              ds, ax
	               mov              ax, stack
	               mov              ss, ax
	               mov              sp, 255

	               print_str        STR_LOGIN
	               auth
	               call             menu
	exit:          
	               mov              ax, 4c00h        	; 退出程序
	               int              21h
start endp


code ends
end start