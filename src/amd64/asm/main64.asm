global LongModeStart
extern KernelMain

section .text
bits 64
LongModeStart:
    ; load null into all data segment registers
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

	call KernelMain
    hlt