; 例 3.9
assume ss: stack, cs: code, ds: data
stack segment
	      db 32 dup(0)
stack ends


data segment
	SB   db 0
	IBUF db 3, 0, 3 dup(0)
data ends


code segment
	start: 
	       push ds
	       sub  ax, ax
	       push ax
	       mov  ax, data
	       mov  ds, ax

	       mov  dx, offset IBUF
	       mov  ah, 10
	       int  21h
	       mov  ax, word ptr IBUF + 2
	       sub  ax, 3030h
	       cmp  al, 0ah
	       jb   LNSUB7
	       sub  al, 7
	LNSUB7:
	       cmp  ah, 0ah
	       jb   HNSUB7
	       sub  ah, 7
	HNSUB7:
	       mov  cl, 4
	       shl  al, cl
	       or   al, ah
	       mov  sb, al
	       mov  ax, 4c00h
	       int  21h
code ends 


end start