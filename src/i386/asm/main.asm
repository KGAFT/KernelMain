global start
extern Main386
extern LongModeStart

section .multiboot_header
header_start:
	; magic number
	dd 0xe85250d6 ; multiboot2
	; architecture
	dd 0 ; protected mode i386
	; header length
	dd header_end - header_start
	; checksum
	dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

	; end tag
	dw 0
	dw 0
	dd 8
header_end:

section .text
bits 32
start:
    mov esp, StackTop ;setting up stack
    call CheckMultiBoot
    call CheckCpuID
    call CheckLongMode

    call SetupMemoryPageTables
    call EnablePaging
	call Main386

    ;Entering into long mode
    lgdt [gdt64.pointer]
    jmp gdt64.codeSegment:LongModeStart


	hlt



SetupMemoryPageTables:
	mov eax, PageTable3
	or eax, 0b11 ; present, writable
	mov [PageTable4], eax

	mov eax, PageTable2
	or eax, 0b11 ; present, writable
	mov [PageTable3], eax

	mov ecx, 0 ; counter
.loop:
	mov eax, 0x200000 ; 2MiB
	mul ecx
	or eax, 0b10000011 ; present, writable, huge page
	mov [PageTable2 + ecx * 8], eax

	inc ecx ; increment counter
	cmp ecx, 512 ; checks if the whole table is mapped
	jne .loop ; if not, continue

	ret


EnablePaging:
	; pass page table location to cpu
	mov eax, PageTable4
	mov cr3, eax

	; enable PAE
	mov eax, cr4
	or eax, 1 << 5
	mov cr4, eax

	; enable long mode
	mov ecx, 0xC0000080
	rdmsr
	or eax, 1 << 8
	wrmsr

	; enable paging
	mov eax, cr0
	or eax, 1 << 31
	mov cr0, eax
    ret

CheckMultiBoot:
    cmp eax, 0x36d76289 ;check if included correctly
    jne .MultiBootNotFoundException
    ret

.MultiBootNotFoundException:
    mov al, "M"
    jmp PrintErrorCode

CheckCpuID: ;Checks if allowed to enable cpu id flag, by flipping its value
    pushfd
    pop eax
   	mov ecx, eax
    xor eax, 1 << 21
   	push eax
   	popfd
   	pushfd
   	pop eax
   	push ecx
   	popfd
   	cmp eax, ecx
   	je .NoCpuIDException
   	ret

.NoCpuIDException:
    mov al, "C"
    jmp PrintErrorCode

CheckLongMode:
    mov eax, 0x80000000
    	cpuid
    	cmp eax, 0x80000001
    	jb .NoLongModeException

    	mov eax, 0x80000001
    	cpuid
    	test edx, 1 << 29
    	jz .NoLongModeException

    	ret

.NoLongModeException:
    mov al, "L"
    jmp PrintErrorCode




PrintErrorCode:
    mov dword [0xb8000], 0x4f524f45
   	mov dword [0xb8004], 0x4f3a4f52
   	mov dword [0xb8008], 0x4f204f20
   	mov byte  [0xb800a], al
   	hlt

section .bss
align 4096
PageTable4:
	resb 4096
PageTable3:
	resb 4096
PageTable2:
	resb 4096
StackBottom:
    resb 4096*4
StackTop:

section .rodata
gdt64:
	dq 0 ; zero entry
.codeSegment: equ $ - gdt64
	dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53) ; code segment
.pointer:
	dw $ - gdt64 - 1 ; length
	dq gdt64 ; address