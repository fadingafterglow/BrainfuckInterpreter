.model tiny
.code   
ORG 0100h
start:
    mov si, 0A0Dh ; init code pointer

    std 
    mov ch, 4Eh ; CX = 4EFFh = 20223
    rep stosb ; zero buffer
    inc di ; init data pointer

    readFile: ; read code from file
        mov ah, 1Ah ; set DTA
        mov dx, si
        int 21h

        mov ah, 0Fh ; open file
        mov dx, 5Ch
        int 21h

        mov ah, 27h 
        mov cl, 79 ; read 79 records (79 * 128 = 10112 bytes) 
        int 21h

    intepretLoop:
        xor ah, ah ; has to be cleaned
        mov al, byte ptr [si]
        inc si ; si points to next instruction

        mov dx, di ; prepare registers for read/write interrupts
        mov cl, 1

        test al, al
        jz exit
        cmp al, '['
        je startLoop
        cmp al, ']'
        je endLoop
        cmp al, '>'
        je incPointer
        cmp al, '<'
        je decPointer
        sub al, '+'
        jz incData
        dec ax ; check ,
        jz readChar
        dec ax ; check - 
        je decData
        dec ax ; check .
        je printChar

        jmp intepretLoop

    exit: ret

    printChar: ; print ascii char to stdout
        mov ah, 40h
        inc bx
        r0: cmp byte ptr [di], 0Ah 
            jne r1
            mov dx, 101h ; points to 0D0Ah in memory
            inc cx
        r1: int 21h
            dec bx
            jmp intepretLoop

    readChar: ; read ascii char from stdin
            mov ah, 3Fh
            int 21h
            cmp byte ptr [di], 0Dh ; change 0Dh to 0Ah
            je readChar ; skip 0Ah
            test al, al ; change EOF to FFFFh
            jnz p0
            mov word ptr [di], 0FFFFh
        p0: jmp intepretLoop

    incData: ; increase element under pointer
        inc word ptr [di]
        jmp intepretLoop

    decData: ; decrase element under pointer 
        dec word ptr [di]
        jmp intepretLoop  

    incPointer: ; increase pointer  
        inc di
        inc di
        jmp intepretLoop    

    decPointer: ; decrease pointer  
        dec di
        dec di
        jmp intepretLoop

    endLoop:
        pop si ; restore first loop instruction

    startLoop:
        push si ; save first loop instruction
    
    checkCondition:
        cmp word ptr [di], bx ; bx = 0        
        jne intepretLoop

        mov al, 1    
        findEnd:
            cmp byte ptr [si], '['
            jne f1
            inc ax
        f1: cmp byte ptr [si], ']'
            jne f2
            dec ax
        f2: inc si   
            test al, al
            jnz findEnd
            pop dx ; remove return address
            jmp intepretLoop

end start