.model tiny
.data
    codeBuffer DB 10001 dup(?)
    dataBuffer DW 10000 dup(?)
.code   
ORG 0100h
start:
    call init

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
        mov cx, 1
        r0: cmp byte ptr [di], 0Ah 
            jne r1
            lea dx, temp
            inc cx
        r1: int 21h
            jmp intepretLoop

    temp: DW 0A0Dh

    readChar: ; read ascii char from stdin
        xor bl, bl
        mov cx, 1
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
        or word ptr [di], 0        
        jnz intepretLoop

        xor al, al
        inc ax        
        findEnd:
            cmp byte ptr [si], '['
            je nestedInc
            cmp byte ptr [si], ']'
            je nestedDec
        updatePointer:    
            inc si
            jmp findEnd
        nestedInc:
            inc ax
            jmp updatePointer
        nestedDec:
            dec ax
            test al, al
            jnz updatePointer
            inc si
            pop dx ; remove return address
            jmp intepretLoop

    init: 
        lea si, codeBuffer ; init pointers
        lea di, dataBuffer   

        mov bl, byte ptr DS:[80h] ; prepare filename
        mov byte ptr [bx+80h+1], 0

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

        mov bx, 20000 ; fill data buffer with zeroes
        fillLoop:
            dec bx
            mov byte ptr [bx+di], 0
            jz f
            jmp fillLoop

        f: ret

end start