.model tiny
.code   
ORG 0100h
start:
    mov si, 0A5Ch ; init code pointer

    std 
    mov ch, 4Eh ; CX = 4EFFh = 20223
    rep stosb ; zero buffer
    inc di ; init data pointer
    cld

    readFile: ; read code from file
        mov ah, 1Ah ; set DTA
        mov dx, si
        int 21h

        mov ah, 0Fh ; open file
        xor dh, dh
        int 21h

        mov ah, 27h 
        mov cl, 125 ; read 125 records (125 * 80 = 10000 bytes) 
        int 21h

    intepretLoop:
        xor ah, ah ; has to be cleaned
        lodsb ; load instruction into al

        mov dx, di ; prepare registers for read interrupt
        mov cl, 1

    c0: test al, al
        jnz c1
            ret ; exit

    c1: cmp al, '['
            je startLoop

    c2: cmp al, ']'
            je endLoop

    c3: cmp al, '>'
        jne c4
            inc di ; increase pointer
            inc di

    c4: cmp al, '<'
        jne c5
            dec di ; decrease pointer
            dec di

    c5: sub al, '+'
        jnz c6
            inc word ptr [di] ; increase element under pointer

    c6: dec ax ; check ,
        jnz c7
            mov word ptr [di], ax ; clear buffer cell
            i0: mov ah, 3Fh ; read ascii char from stdin
                int 21h
                cmp byte ptr [di], 0Dh ; change 0Dh to 0Ah
                je i0 ; skip to 0Ah
                dec ax ; check if we have reached EOF
                jnz i1

    c7: dec ax ; check - 
        jnz c8
        i1: dec word ptr [di] ; decrase element under pointer

    c8: dec ax ; check .
        jnz c9
            mov ah, 02h
            cmp byte ptr [di], 0Ah 
            jne p1
                mov dl, 0Dh
                int 21h
            p1: mov dl, byte ptr [di]
                int 21h

    c9: jmp intepretLoop


    endLoop:
        pop si ; restore first loop instruction

    startLoop:
        push si ; save first loop instruction
    
    checkCondition: 
        cmp word ptr [di], bx ; bx = 0        
        jne intepretLoop
 
        findEnd:
            lodsb ; load instruction into al
            cmp al, '['
            jne f1
            inc cx
        f1: cmp al, ']'
            jne f2
            dec cx
        f2: jnz findEnd
            pop dx ; remove return address
            jmp intepretLoop

end start