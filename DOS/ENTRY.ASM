.model tiny
.data
    codeBuffer DB 10001 dup(?)
    dataBuffer DW 10000 dup(?)
.code   
ORG 0100h
start:
    xor ax, ax 

    call init
    call readFile

    call readChar
    call printChar

    ret


    readFile: ; after: BX = number of bytes read
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

    init: ; init pointers
        lea si, codeBuffer 
        lea di, dataBuffer   
        ret

    printChar: ; print ascii char to stdout
        mov ah, 40h
        mov bx, 1
        mov cx, 1
        mov dx, di
        int 21h
        ret

    readChar: ; read ascii char from stdin
        mov ah, 3Fh
        mov bx, 0
        mov cx, 1
        mov dx, di
        int 21h
        cmp byte ptr DS:[di], 0Dh ; change 0Dh to 0Ah
        jne e
        mov byte ptr DS:[di], 0Ah
        e: ret

    flushCodeBuffer: ; print code buffer to stdout (for debug purposes)
        mov ah, 40h
        mov dx, si
        mov cx, bx
        inc cx
        mov bx, 1
        int 21h
        ret

end start

