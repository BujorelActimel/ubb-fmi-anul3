.section .rodata
fmt_in: .string "%d"
fmt_out: .string "%d\n"

.text
.globl main

main:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp
    leaq -8(%rbp), %rsi
    leaq fmt_in(%rip), %rdi
    xorq %rax, %rax
    call scanf@PLT
    leaq -16(%rbp), %rsi
    leaq fmt_in(%rip), %rdi
    xorq %rax, %rax
    call scanf@PLT
    movq -8(%rbp), %rax
    pushq %rax
    movq -16(%rbp), %rax
    pushq %rax
    movq $2, %rax
    movq %rax, %rbx
    popq %rax
    imulq %rbx, %rax
    movq %rax, %rbx
    popq %rax
    addq %rbx, %rax
    movq %rax, -24(%rbp)
    movq -24(%rbp), %rax
    movq %rax, %rsi
    leaq fmt_out(%rip), %rdi
    xorq %rax, %rax
    call printf@PLT
    movq %rbp, %rsp
    popq %rbp
    xorq %rax, %rax
    ret
