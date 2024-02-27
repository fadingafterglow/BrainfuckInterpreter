section .data
;    path: dw "/home/kali/Documents/test"
    errormsg: dw "File not found"
    
section .bss
    buffer: resb 10000
        
section .text
global main
main:
;    mov ebp, esp; for correct debugging
;    
;    push path ; emulating comand line params
;    push 0x00000000
;    push 2
    
    pop eax ; check comand line params
    cmp eax, 2
    jne nofile
    
    pop eax ; pop program name
    
    mov eax, 5 ; open file
    pop ebx
    mov ecx, 0
    int 80h

    cmp eax, 0 ; check if file was opened
    jl nofile

    mov ebx, eax ; read file in buffer
    mov eax, 3
    mov ecx, buffer
    mov edx, 10000
    int 80h
    
    mov edx, eax ; print file content to stdout
    mov eax, 4
    mov ecx, buffer
    mov ebx, 1
    int 80h
    
    jmp exit
    
nofile:
    mov eax, 4 ; print error message to stderr
    mov ebx, 2
    mov ecx, errormsg
    mov edx, 14    
    int 80h
    
exit:    
    mov eax, 1 ; exit the program
    mov ebx, 0
    int 80h