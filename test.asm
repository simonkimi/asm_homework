assume cs: code, ds: data, ss: stack


print_str macro A
	          mov ah, 9
	          mov dx, offset A
	          int 21h
endm


data segment
	NUM  dw 000ah, 1111h, 8888h, 2222h, 7777h, 5555h, 9999h, 7777h, 1111h, 3333h, 4444h
data ends


stack segment
	      db 255 dup(0)
stack ends


code segment

start proc near
	           mov  ax, data
	           mov  ds, ax

	           mov  ax, stack
	           mov  ss, ax
	           mov  sp, 255
	      

	           mov  cx, NUM[0]
	           dec  cx
	sort_outer:
	           mov  dx, cx
	           mov  bx, 0
	sort_inner:
	           mov  ax, NUM[bx + 2]
	           cmp  ax, NUM[bx + 4]
	           jb   chg_finish
	           xchg ax, NUM[bx + 4]
	           mov  NUM[bx + 2], ax
	chg_finish:
	           add  bx, 2
	           dec  dx
	           cmp  dx, 0
	           jne  sort_inner
	           loop sort_outer

	           mov  ax, 4c00h
	           int  21h
start endp
	     

code ends
end start