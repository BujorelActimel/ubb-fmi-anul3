.section .rodata
fmt_in: .string "%d"
fmt_out: .string "%d\n"

.text
.globl main

main:
    pushq %rbp
    movq %rsp, %rbp
    movq $10, %rax
    pushq %rax
    movq $20, %rax
    pushq %rax
    movq $3, %rax
    movq %rax, %rbx
    popq %rax
    subq %rbx, %rax
    movq %rax, %rbx
    popq %rax
    imulq %rbx, %rax
    pushq %rax
    movq $4, %rax
    movq %rax, %rbx
    popq %rax
    cqo
    idivq %rbx
    movq %rax, -1(%rbp)
    movq -1(%rbp), %rax
    movq %rax, %rsi
    leaq fmt_out(%rip), %rdi
    xorq %rax, %rax
    call printf@PLT
    movq %rbp, %rsp
    popq %rbp
    xorq %rax, %rax
    ret
