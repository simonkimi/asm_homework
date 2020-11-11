; 习题 3.16
include macro.lib
assume cs: code, ds: data, ss: stack


data segment
	IBUF db 255, 0, 255 dup(0)
	OBUF db 255 dup(0)
data ends


stack segment
	      db 255 dup(0)
stack ends


code segment
start proc near
	      mov        ax, data
	      mov        ds, ax

	      mov        ax, stack
	      mov        ss, ax
	      mov        sp, 255

	      input_str  IBUF
	      print_line
	      mov        ax, 0
	      mov        cl, IBUF[1]      	; 数据长度
	      mov        ch, 0
	      mov        bx, 1
	store:
	      add        bx, 1
	      mov        al, IBUF[bx]
	      push       ax
	      loop       store

	      mov        cl, IBUF[1]      	; 数据长度
	      mov        bx, 0
	read: 
	      pop        ax
	      mov        OBUF[bx], al
	      add        bx, 1
	      mov        OBUF[bx + 1], 0dh
	      mov        OBUF[bx + 2], 0ah
	      mov        OBUF[bx + 3], '$'
	      loop       read
	      print_str  OBUF

	      mov        ax, 4c00h
	      int        21h
start endp
code ends
end start