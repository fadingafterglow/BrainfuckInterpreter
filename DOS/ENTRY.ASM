.model tiny
.code   
ORG 0100h
start:
    xor ax, ax 

    call readFile

    mov ah, 40h
    mov dx, codeBuffer
    mov cx, bx
    mov bx, 1
    int 21h

    ret


    readFile: ; after: BX = number of bytes read
        xor bx, bx ; prepare filename
        mov bl, DS:[80h]
        mov [bx+80h+1], 0

        mov ah, 3Dh ; open file
        mov dx, 0082h 
        int 21h

        mov bx, ax ; save file handler

        mov ax, 3F00h ; read into buffer
        mov dx, codeBuffer
        mov cx, 10000
        int 21h

        mov bx, ax ; add terminator to code buffer
        mov [bx+codeBuffer], 0
        ret

    codeBuffer equ 500h
    dataBuffer equ 10502h
end start

