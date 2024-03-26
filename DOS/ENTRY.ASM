.model tiny
.code   
ORG 0100h
start:
    readFile: ; read code from file
        mov ax, 1A5Ch ; set DTA
        mov dh, 0Fh
        int 21h

        mov si, dx ; init code pointer

        cbw
        xchg ax, dx ; ah = 0Fh dx = 005Ch 
        int 21h ; open file

        mov ah, 27h
        sub byte ptr [bx+6Bh], ah ; set record size to D980h (= 55680) bytes
        int 21h ; read code from file and zero bytes till the F3DCh (= 62428)
                        
    shr di, cl ; init data pointer (FFFEh = 65534  -> 7FFFh = 32767)

    intepretLoop:
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
                    pop si ; restore first loop instruction
                
                startLoop:
                    jcxz balanceL
                    push si ; save first loop instruction

                checkCondition: 
                    cmp word ptr [di], bx ; bx = 0        
                    jne intepretLoop
                    dec cx ; start bracket balancing

                balanceL:
                    inc bx
                    inc bx

                balanceR:
                    dec bx
                    jnz intepretLoop
                    pop dx ; remove return address from the stack
                    inc cx ; stop bracket balancing

    c3: jcxz intepretLoop ; cx == 0 means that we are balancing brackets

    c4: cmp al, '>'
        jne c5
            inc di ; increase pointer
            inc di

    c5: cmp al, '<'
        jne c6
            dec di ; decrease pointer
            dec di

    c6: sub al, '+'
        jnz c7
            inc word ptr [di] ; increase element under pointer

    c7: dec ax ; check ,
        jnz c8
            mov word ptr [di], ax ; clear buffer cell
            mov dx, di
            i0: mov ah, 3Fh ; read ascii char from stdin
                int 21h
                cmp byte ptr [di], 0Dh ; change 0Dh to 0Ah
                je i0 ; skip to 0Ah
                dec ax ; check if we have reached EOF
                jnz i1

    c8: dec ax ; check - 
        jnz c9
        i1: dec word ptr [di] ; decrase element under pointer

    c9: dec ax ; check .
        jnz c10
            mov ah, 02h
            cmp byte ptr [di], 0Ah 
            jne p1
                mov dl, 0Dh
                int 21h
            p1: mov dl, byte ptr [di]
                int 21h

    c10: jmp intepretLoop

end start