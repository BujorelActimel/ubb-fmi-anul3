package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:thread"
import "core:time"

SIZE :: 100_000_000

a: [dynamic]int
b: [dynamic]int
c: [dynamic]int

gen_vect :: proc(copy: ^[dynamic]int) {
    for i in 0..<SIZE {
        append(copy, rand.int_max(100) + 1)
    }
}

print_vector :: proc(copy: ^[dynamic]int) {
    for i in 0..<SIZE {
        fmt.print(copy[i], " ")
    }
    fmt.println()
}

oper :: proc(x, y: int) -> int {
    // return x + y
    return int(math.sqrt(f64(x*x*x*x*x + y*y*y*y*y)))
}

solve :: proc(ss, ee: int) {
    for i in ss..<ee {
        c[i] = oper(a[i], b[i])
    }
}

run :: proc(number_of_threads: int = 1) {
    threads := make([dynamic]^thread.Thread)
    defer delete(threads)

    start := 0

    chunk := SIZE / number_of_threads
    remaining := SIZE % number_of_threads

    start_time := time.now()

    for i in 0..<number_of_threads {
        end_thread := start + chunk
        if i < remaining {
            end_thread += 1
        }

        t := thread.create_and_start_with_poly_data2(start, end_thread, solve)
        append(&threads, t)

        start = end_thread
    }

    for t in threads {
        thread.join(t)
        thread.destroy(t)
    }

    if SIZE < 10 {
        print_vector(&a)
        print_vector(&b)
        print_vector(&c)
    }

    end_time := time.now()
    duration := time.diff(start_time, end_time)
    fmt.printf("Timpul de executie: %v ms\n", time.duration_milliseconds(duration))
}

main :: proc() {
    a = make([dynamic]int, 0, SIZE)
    b = make([dynamic]int, 0, SIZE)
    c = make([dynamic]int, SIZE)
    defer delete(a)
    defer delete(b)
    defer delete(c)

    gen_vect(&a)
    gen_vect(&b)

    run(5)
}
