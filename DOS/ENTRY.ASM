.model tiny
.code   
ORG 0100h
start:  ; expected startup values BX = 0000h, CX = 00FFh, DI = FFFEh
    readSourceCode:
        mov ax, 1A5Ch
        mov dh, 0Fh
        int 21h ; set DTA

        mov si, dx ; init code pointer

        cbw
        xchg ax, dx ; ah = 0Fh dx = 005Ch 
        int 21h ; open file

        mov ah, 27h
        sub byte ptr [bx+6Bh], ah ; set record size to D980h (= 55680) bytes
        int 21h ; read code from file and zero bytes till the F3DCh (= 62428)
                        
    shr di, cl ; init data pointer (FFFEh = 65534 -> 7FFFh = 32767)

    intepreterCycle:
        lodsb ; load instruction into al
        
    c0: aad 0 ; clean ah, check if al == 0
        jnz c1
            ret ; exit

    c1: cmp al, '['
            je startLoop

    c2: cmp al, ']'
            jne c3        
                endLoop:
                    jcxz balanceR
                    pop si ; restore first instruction of the loop
                
                startLoop:
                    jcxz balanceL
                    push si ; save first instruction of the loop

                checkCondition: 
                    cmp word ptr [di], bx ; bx = 0        
                    jne intepreterCycle
                    dec cx ; start bracket balancing

                balanceL:
                    inc bx ; nesting level + 1 
                    inc bx

                balanceR:
                    dec bx ; nesting level - 1
                    jnz intepreterCycle
                    pop dx ; remove return address from the stack
                    inc cx ; stop bracket balancing

    c3: jcxz intepreterCycle ; cx == 0 means that we are balancing brackets

    c4: cmp al, '>'
        jne c5
            inc di ; increase data pointer
            inc di

    c5: cmp al, '<'
        jne c6
            dec di ; decrease data pointer
            dec di

    c6: sub al, '+'
        jnz c7
            inc word ptr [di] ; increase element under data pointer

    c7: dec ax ; check for ','
        jnz c8
            mov word ptr [di], ax ; clear buffer cell
            mov dx, di
            i0: mov ah, 3Fh ; read ascii char from stdin
                int 21h
                cmp byte ptr [di], 0Dh ; check input for 0Dh
                je i0 ; skip to 0Ah
                dec ax ; check if we have reached EOF
                jnz i1

    c8: dec ax ; check for '-'
        jnz c9
        i1: dec word ptr [di] ; decrase element under data pointer

    c9: dec ax ; check for '.'
        jnz c10
            mov ah, 02h
            cmp byte ptr [di], 0Ah ; check buffer for 0Ah
            jne p1
                mov dl, 0Dh
                int 21h ; expand 0Ah to 0D0Ah
            p1: mov dl, byte ptr [di]
                int 21h ; print ascii char to stdout

    c10: jmp intepreterCycle

end start