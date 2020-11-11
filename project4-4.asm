; 例 3.23
assume cs: code, ss: stack, ds: data

stack segment
	      dw 32 dup(0)
stack ends

data segment
	A    db  11h, 12h, 13h, 14h, 15h
	N    equ $ - A
	     db  21h, 22h, 23h, 24h, 25h
	     db  31h, 32h, 33h, 34h, 35h
	     db  41h, 42h, 43h, 44h, 45h
	M    equ ($ - A) / N
	S    dw  M dup(0)
data ends

code segment
	start:  
	        push ds
	        sub  ax, ax
	        push ax
	        mov  ax, data
	        mov  ds, ax
	        mov  bx, M
	        mov  si, offset A
	        mov  di, offset S

	outside:
	        mov  cx, N
	        mov  dx, 0
	inside: 
	        mov  al, [si]
	        cbw
	        add  dx, ax
	        inc  si
	        loop inside
	        mov  [di], dx
	        add  di, 2
	        dec  bx
	        jnz  outside
            

	        mov  ax, 4c00h
	        int  21h

code ends 


end start