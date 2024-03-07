.model tiny
.data
    codeBuffer DB 10001 dup(?)
    dataBuffer DW 10000 dup(?)
.code   
ORG 0100h
start:
    xor ax, ax 

    call init

    intepretLoop:
        mov ah, byte ptr [si]
        inc si

        cmp ah, 0
        je exit
        cmp ah, '+'
        je incData
        cmp ah, '-'
        je decData
        cmp ah, '>'
        je incPointer
        cmp ah, '<'
        je decPointer
        cmp ah, '.'
        je printChar
        cmp ah, ','
        je readChar

        jmp intepretLoop

    exit: ret

    printChar: ; print ascii char to stdout
        mov ah, 40h
        mov bx, 1
        mov cx, 1
        mov dx, di
        int 21h
        jmp intepretLoop

    readChar: ; read ascii char from stdin
        mov ah, 3Fh
        mov bx, 0
        mov cx, 1
        mov dx, di
        int 21h

    check0Dh: ; change 0Dh to 0Ah
        cmp byte ptr DS:[di], 0Dh 
        jne e
        mov byte ptr DS:[di], 0Ah
        e: jmp intepretLoop

    incData: ; increase element under pointer
        inc word ptr [di]
        jmp check0Dh

    decData: ; decrase element under pointer 
        dec word ptr [di]
        jmp check0Dh  

    incPointer: ; increase pointer  
        inc di
        inc di
        jmp intepretLoop    

    decPointer: ; decrease pointer  
        dec di
        dec di
        jmp intepretLoop

    init: 
        lea si, codeBuffer ; init pointers
        lea di, dataBuffer   

        xor bx, bx ; prepare filename
        mov bl, byte ptr DS:[80h]
        mov byte ptr DS:[bx+80h+1], 0

        mov ah, 3Dh ; open file
        mov dx, 0082h 
        int 21h

        mov bx, ax ; save file handler
        mov ah, 3Fh ; read into buffer
        mov dx, si
        mov cx, 10000
        int 21h

        mov bx, ax ; add terminator to code buffer
        mov byte ptr [bx+si], 0
        ret

end start

