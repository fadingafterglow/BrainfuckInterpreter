.model tiny
.data
    codeBuffer DB 10001 dup(?)
    dataBuffer DW 10000 dup(?)
.code   
ORG 0100h
start:
    lea si, codeBuffer ; init pointers
    lea di, dataBuffer   

    fileReading: ; read code from file
        mov ah, 1Ah ; set DTA
        mov dx, si
        int 21h

        mov ah, 0Fh ; open file
        mov dx, 5Ch
        int 21h

        mov ah, 27h 
        mov cl, 79 ; read 79 records (79 * 128 = 10112 bytes) 
        int 21h

    mov bx, 20000 
    fillLoop: ; fill data buffer with zeroes
        dec bx
        mov byte ptr [bx+di], 0
        jz intepretLoop
        jmp fillLoop

    intepretLoop:
        xor ah, ah ; has to be cleaned
        mov al, byte ptr [si]
        inc si ; si points to next instruction

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
        mov bl, 1
        mov dx, di
        mov cl, 1
        r0: cmp byte ptr [di], 0Ah 
            jne r1
            lea dx, temp
            inc cx
        r1: int 21h
            jmp intepretLoop

    temp: DW 0A0Dh

    readChar: ; read ascii char from stdin
        xor bl, bl
        mov cl, 1
        mov dx, di
        p0: mov ah, 3Fh
            int 21h
            cmp byte ptr [di], 0Dh ; change 0Dh to 0Ah
            jne p1
            jmp p0 ; skip 0Ah
        p1: test al, al ; change EOF to FFFFh
            jnz p2
            mov word ptr [di], 0FFFFh
        p2: jmp intepretLoop

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
        cmp word ptr [di], 0        
        jnz intepretLoop

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