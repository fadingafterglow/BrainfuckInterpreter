  BITS 32      
                org     0x08048000
  ehdr:                                                 ; Elf32_Ehdr
                db      0x7F, "ELF", 1, 1, 1, 0         ;   e_ident
        times 8 db      0
                dw      2                               ;   e_type
                dw      3                               ;   e_machine
                dd      1                               ;   e_version
                dd      _start                          ;   e_entry
                dd      phdr - $$                       ;   e_phoff
                dd      0                               ;   e_shoff
                dd      0                               ;   e_flags
                dw      ehdrsize                        ;   e_ehsize
                dw      phdrsize                        ;   e_phentsize
                dw      1                               ;   e_phnum
                dw      0                               ;   e_shentsize
                dw      0                               ;   e_shnum
                dw      0                               ;   e_shstrndx
  
  ehdrsize      equ     $ - ehdr
  
  phdr:                                                 ; Elf32_Phdr
                dd      1                               ;   p_type
                dd      0                               ;   p_offset
                dd      $$                              ;   p_vaddr
                dd      $$                              ;   p_paddr
                dd      filesize                        ;   p_filesz
                dd      filesize + 10000                ;   p_memsz
                dd      7                               ;   p_flags
                dd      0x1000                          ;   p_align
  
  phdrsize      equ     $ - phdr

_start:
    pop eax ; pop args count
    pop eax ; pop program name
    pop ebx ; pop file path
    
    call read_file
    
    cmp eax, 0 ; check if file was read
    jl _nofile
    
    call print_file
    
    jmp _exit
    
_nofile:
    mov eax, 4 ; print error message to stderr
    mov ebx, 2
    mov ecx, errormsg
    mov edx, 14    
    int 80h
    
_exit:    
    mov eax, 1 ; exit the program
    mov ebx, 0
    int 80h
    
; variables    
errormsg: DB "File not found"    
    
; procedures
read_file:    
    mov eax, 5 ; open file
    mov ecx, 0
    int 80h
    mov ecx, 0x08048000+filesize 	
    mov ebx, eax ; read file in buffer
    mov eax, 3
    mov edx, 10000
    int 80h
    ret
    
print_file:
    mov edx, eax ; print file content to stdout
    mov eax, 4
    mov ebx, 1
    int 80h
    ret
    
  filesize      equ     $ - $$
