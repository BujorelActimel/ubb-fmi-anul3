package main

import "core:fmt"
import "core:math/rand"
import "core:time"
import "core:thread"

VEC_SIZE :: 1000000
NO_THREADS :: 4

generate_vector :: proc(size: int, upper_bound: int) -> []int {
    vec := make([]int, size)

    for i in 0..<size {
        vec[i] = int(rand.int31_max(i32(upper_bound)))
    }

    return vec
}

print_vector :: proc(vec: []int) {
    for val in vec {
        fmt.printf("%d ", val)
    }
    fmt.println()
}

sum_vectors_seq :: proc(a: []int, b: []int) -> []int {
    size := len(a)
    c := make([]int, size)

    for i in 0..<size {
        c[i] = a[i] + b[i]
    }

    return c
}

Thread_Data :: struct {
    start: int,
    end: int,
    a: []int,
    b: []int,
    c: []int,
}

interval_thread_func :: proc(t: ^thread.Thread) {
    data := cast(^Thread_Data)t.data

    for i in data.start..<data.end {
        data.c[i] = data.a[i] + data.b[i]
    }
}

sum_vectors_interval :: proc(a: []int, b: []int, no_threads: int) -> []int {
    size := len(a)
    c := make([]int, size)
    threads := make([]^thread.Thread, no_threads)
    thread_data := make([]Thread_Data, no_threads)
    chunk_size := size / no_threads

    for i in 0..<no_threads {
        start := i * chunk_size
        end := size if i == no_threads - 1 else (i + 1) * chunk_size

        thread_data[i] = Thread_Data{
            start = start,
            end = end,
            a = a,
            b = b,
            c = c,
        }

        threads[i] = thread.create(interval_thread_func)
        threads[i].data = &thread_data[i]
        thread.start(threads[i])
    }

    for t in threads {
        thread.join(t)
    }

    delete(threads)
    delete(thread_data)

    return c
}

main :: proc() {
    fmt.println("PPD - Lab2 (Odin Implementation)")
    fmt.printf("Vector size: %d\n", VEC_SIZE)
    fmt.printf("Number of threads: %d\n", NO_THREADS)
    fmt.println()

    rand.reset(u64(time.now()._nsec))

    a := generate_vector(VEC_SIZE, 10)
    b := generate_vector(VEC_SIZE, 10)

    // Sequential timing
    start_time := time.now()
    c_seq := sum_vectors_seq(a, b)
    end_time := time.now()
    duration := time.diff(start_time, end_time)
    ms := time.duration_milliseconds(duration)
    fmt.printf("Sequential time: %.0f ms\n", ms)

    if VEC_SIZE <= 10 {
        fmt.print("Vector A: ")
        print_vector(a)
        fmt.print("Vector B: ")
        print_vector(b)
        fmt.print("Vector C (Sequential): ")
        print_vector(c_seq)
        fmt.println()
    }

    // Interval timing
    start_time = time.now()
    c_int := sum_vectors_interval(a, b, NO_THREADS)
    end_time = time.now()
    duration = time.diff(start_time, end_time)
    ms = time.duration_milliseconds(duration)
    fmt.printf("Interval time: %.0f ms\n", ms)

    if VEC_SIZE <= 10 {
        fmt.print("Vector C (Interval): ")
        print_vector(c_int)
        fmt.println()
    }

    delete(a)
    delete(b)
    delete(c_seq)
    delete(c_int)
}
