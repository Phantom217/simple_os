extern kmain

global start

section .text
bits 32
start:

    ; Point the first entry of the level 4 page table to the first entry in the
    ; p3 table
    mov eax, p3_table
    or eax, 0b11
    mov dword [p4_table + 0], eax

    ; Point the first entry of the level 3 page table to the first entry in the
    ; p2 table
    mov eax,p2_table
    or eax, 0b11
    mov dword [p3_table + 0], eax

    ; point each page table level two entry to a page
    mov ecx, 0          ; counter variable
.map_p2_table:
    mov eax, 0x200000   ; 2MiB
    mul ecx
    or eax, 0b10000011
    mov [p2_table + ecx * 8], eax

    inc ecx
    cmp ecx, 512
    jne .map_p2_table

    ; move page table address to cr3
    mov eax, p4_table
    mov cr3, eax

    ; enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; set the long mode bit
    mov ecx, 0xC0000080
    rdmsr       ; read 'model specific register'
    or eax, 1 << 8
    wrmsr       ; write 'model specific register'

    ; enable paging
    mov eax, cr0
    or eax, 1 << 31
    or eax, 1 << 16
    mov cr0, eax

    ; load global descriptor table
    lgdt [gdt64.pointer]

    ; update selectors
    mov ax, gdt64.data  ; ax is a sixteen-bit register
    mov ss, ax          ; ss is the stack segment register
    mov ds, ax          ; ds is the data segment register
    mov es, ax          ; es is an extra segment register

    ; jump to long mode
    jmp gdt64.code:kmain

    hlt

section .bss ; bss = 'block started by symbol'
align 4096 ; aligned to 4096 byte chunks
p4_table:
    resb 4096 ; reserved bytes
p3_table:
    resb 4096
p2_table:
    resb 4096

section .rodata
gdt64:
    dq 0    ; zero entry
.code: equ $ - gdt64
    dq (1<<44) | (1<<47) | (1<<41) | (1<<43) | (1<<53) ; code segment
.data: equ $ - gdt64
    dq (1<<44) | (1<<47) | (1<<41)  ; data segment
.pointer:
    dw .pointer - gdt64 - 1
    dq gdt64
