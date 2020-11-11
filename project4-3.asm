; 例 3.8
assume cs: code, ss: stack, ds: data

stack segment
	      dw 32 dup(0)
stack ends

data segment
	SB   db 9ah
	OBUF db 0, 0, 0
data ends

code segment
	start:
	      push ds
	      sub  ax, ax
	      push ax
	      mov  ax, data
	      mov  ds, ax

	      mov  cx, 204h
	      mov  bx, 0
	      mov  al, SB
	AGAIN:
	      mov  ah, 3
	      shl  ax, cl
	      cmp  ah, 39h
	      jbe  NAD7
	      add  ah, 7
	NAD7: 
	      mov  OBUF[bx], ah
	      inc  bx
	      dec  ch
	      jnz  AGAIN
	      mov  OBUF[bx], '$'
	      mov  dx, offset OBUF
	      mov  ah, 9
	      int  21h
	      mov  ax, 4c00h
	      int  21h

code ends 


end start