package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:time"
import "core:thread"
import "core:math"
import "core:slice"

Strategy :: enum {
    Sequential,
    Horizontal,
    Vertical,
    Block,
}

Config :: struct {
    input_file: string,
    execution_mode: string,
    num_threads: int,
    strategy: Strategy,
}

Matrix :: struct {
    data: []int,
    rows: int,
    cols: int,
}

ConvolutionData :: struct {
    F: Matrix,
    C: Matrix,
    V: Matrix,
    n, m, k: int,
}

ThreadData :: struct {
    data: ^ConvolutionData,
    start_row: int,
    end_row: int,
    start_col: int,
    end_col: int,
}

matrix_get :: proc(m: ^Matrix, row, col: int) -> int {
    return m.data[row * m.cols + col]
}

matrix_set :: proc(m: ^Matrix, row, col, value: int) {
    m.data[row * m.cols + col] = value
}

get_F_clamped :: proc(data: ^ConvolutionData, row, col: int) -> int {
    clamped_row := clamp(row, 0, data.n - 1)
    clamped_col := clamp(col, 0, data.m - 1)
    return matrix_get(&data.F, clamped_row, clamped_col)
}

compute_pixel :: proc(data: ^ConvolutionData, i, j: int) -> int {
    result := 0
    half_k := data.k / 2

    for di in 0..<data.k {
        for dj in 0..<data.k {
            fi := i + di - half_k
            fj := j + dj - half_k
            f_val := get_F_clamped(data, fi, fj)
            c_val := matrix_get(&data.C, di, dj)
            result += f_val * c_val
        }
    }

    return result
}

sequential_convolution :: proc(data: ^ConvolutionData) {
    for i in 0..<data.n {
        for j in 0..<data.m {
            matrix_set(&data.V, i, j, compute_pixel(data, i, j))
        }
    }
}

thread_worker :: proc(t: ^thread.Thread) {
    thread_data := cast(^ThreadData)t.data
    data := thread_data.data

    for i in thread_data.start_row..<thread_data.end_row {
        for j in thread_data.start_col..<thread_data.end_col {
            matrix_set(&data.V, i, j, compute_pixel(data, i, j))
        }
    }
}

horizontal_convolution :: proc(data: ^ConvolutionData, num_threads: int) {
    threads := make([]^thread.Thread, num_threads)
    thread_datas := make([]ThreadData, num_threads)
    defer delete(threads)
    defer delete(thread_datas)

    rows_per_thread := data.n / num_threads
    remainder := data.n % num_threads

    start_row := 0
    for i in 0..<num_threads {
        extra := 1 if i < remainder else 0
        rows := rows_per_thread + extra

        thread_datas[i] = ThreadData{
            data = data,
            start_row = start_row,
            end_row = start_row + rows,
            start_col = 0,
            end_col = data.m,
        }

        threads[i] = thread.create(thread_worker)
        threads[i].data = &thread_datas[i]
        thread.start(threads[i])

        start_row += rows
    }

    for t in threads {
        thread.join(t)
    }

    for t in threads {
        thread.destroy(t)
    }
}

vertical_convolution :: proc(data: ^ConvolutionData, num_threads: int) {
    threads := make([]^thread.Thread, num_threads)
    thread_datas := make([]ThreadData, num_threads)
    defer delete(threads)
    defer delete(thread_datas)

    cols_per_thread := data.m / num_threads
    remainder := data.m % num_threads

    start_col := 0
    for i in 0..<num_threads {
        extra := 1 if i < remainder else 0
        cols := cols_per_thread + extra

        thread_datas[i] = ThreadData{
            data = data,
            start_row = 0,
            end_row = data.n,
            start_col = start_col,
            end_col = start_col + cols,
        }

        threads[i] = thread.create(thread_worker)
        threads[i].data = &thread_datas[i]
        thread.start(threads[i])

        start_col += cols
    }

    for t in threads {
        thread.join(t)
    }

    for t in threads {
        thread.destroy(t)
    }
}

block_convolution :: proc(data: ^ConvolutionData, num_threads: int) {
    grid_rows := int(math.sqrt(f64(num_threads)))
    grid_cols := num_threads / grid_rows

    for grid_rows * grid_cols < num_threads {
        grid_cols += 1
    }

    threads := make([]^thread.Thread, num_threads)
    thread_datas := make([]ThreadData, num_threads)
    defer delete(threads)
    defer delete(thread_datas)

    rows_per_block := data.n / grid_rows
    cols_per_block := data.m / grid_cols
    row_remainder := data.n % grid_rows
    col_remainder := data.m % grid_cols

    thread_idx := 0
    current_row := 0

    for grid_i in 0..<grid_rows {
        extra_rows := 1 if grid_i < row_remainder else 0
        block_rows := rows_per_block + extra_rows

        current_col := 0
        for grid_j in 0..<grid_cols {
            if thread_idx >= num_threads {
                break
            }

            extra_cols := 1 if grid_j < col_remainder else 0
            block_cols := cols_per_block + extra_cols

            thread_datas[thread_idx] = ThreadData{
                data = data,
                start_row = current_row,
                end_row = current_row + block_rows,
                start_col = current_col,
                end_col = current_col + block_cols,
            }

            threads[thread_idx] = thread.create(thread_worker)
            threads[thread_idx].data = &thread_datas[thread_idx]
            thread.start(threads[thread_idx])

            current_col += block_cols
            thread_idx += 1
        }

        current_row += block_rows
    }

    for i in 0..<thread_idx {
        thread.join(threads[i])
    }

    for i in 0..<thread_idx {
        thread.destroy(threads[i])
    }
}

read_input :: proc(filename: string) -> (ConvolutionData, bool) {
    data: ConvolutionData

    file_data, ok := os.read_entire_file(filename)
    if !ok {
        fmt.eprintln("Error: Could not read input file")
        return data, false
    }
    defer delete(file_data)

    content := string(file_data)
    lines := strings.split_lines(content)
    defer delete(lines)

    line_idx := 0

    dims := strings.fields(lines[line_idx])
    defer delete(dims)
    line_idx += 1

    data.n, _ = strconv.parse_int(dims[0])
    data.m, _ = strconv.parse_int(dims[1])
    data.k, _ = strconv.parse_int(dims[2])

    data.F = Matrix{
        data = make([]int, data.n * data.m),
        rows = data.n,
        cols = data.m,
    }

    data.C = Matrix{
        data = make([]int, data.k * data.k),
        rows = data.k,
        cols = data.k,
    }

    data.V = Matrix{
        data = make([]int, data.n * data.m),
        rows = data.n,
        cols = data.m,
    }

    for i in 0..<data.n {
        if line_idx >= len(lines) || lines[line_idx] == "" {
            line_idx += 1
            if line_idx >= len(lines) {
                break
            }
        }

        values := strings.fields(lines[line_idx])
        defer delete(values)
        line_idx += 1

        for j in 0..<min(data.m, len(values)) {
            val, _ := strconv.parse_int(values[j])
            matrix_set(&data.F, i, j, val)
        }
    }

    for i in 0..<data.k {
        if line_idx >= len(lines) || lines[line_idx] == "" {
            line_idx += 1
            if line_idx >= len(lines) {
                break
            }
        }

        values := strings.fields(lines[line_idx])
        defer delete(values)
        line_idx += 1

        for j in 0..<min(data.k, len(values)) {
            val, _ := strconv.parse_int(values[j])
            matrix_set(&data.C, i, j, val)
        }
    }

    return data, true
}

write_output :: proc(data: ^ConvolutionData, filename: string) -> bool {
    builder := strings.builder_make()
    defer strings.builder_destroy(&builder)

    fmt.sbprintf(&builder, "%d %d\n", data.n, data.m)

    for i in 0..<data.n {
        for j in 0..<data.m {
            if j > 0 do fmt.sbprint(&builder, " ")
            fmt.sbprintf(&builder, "%d", matrix_get(&data.V, i, j))
        }
        fmt.sbprint(&builder, "\n")
    }

    output := strings.to_string(builder)
    ok := os.write_entire_file(filename, transmute([]byte)output)
    return ok
}

parse_args :: proc() -> (Config, bool) {
    config := Config{
        strategy = .Sequential,
        num_threads = 1,
    }

    args := os.args[1:]

    for i := 0; i < len(args); i += 1 {
        arg := args[i]

        if arg == "-i" && i + 1 < len(args) {
            i += 1
            config.input_file = args[i]
        } else if arg == "-e" && i + 1 < len(args) {
            i += 1
            config.execution_mode = args[i]
        } else if arg == "-t" && i + 1 < len(args) {
            i += 1
            config.num_threads, _ = strconv.parse_int(args[i])
        } else if arg == "-s" && i + 1 < len(args) {
            i += 1
            strategy_str := args[i]
            switch strategy_str {
            case "horizontal":
                config.strategy = .Horizontal
            case "vertical":
                config.strategy = .Vertical
            case "block":
                config.strategy = .Block
            case:
                fmt.eprintln("Unknown strategy:", strategy_str)
                return config, false
            }
        }
    }

    if config.input_file == "" {
        fmt.eprintln("Error: -i (input file) is required")
        return config, false
    }

    if config.execution_mode == "" {
        fmt.eprintln("Error: -e (execution mode) is required")
        return config, false
    }

    return config, true
}

main :: proc() {
    config, ok := parse_args()
    if !ok {
        os.exit(1)
    }

    data, read_ok := read_input(config.input_file)
    if !read_ok {
        os.exit(1)
    }
    defer delete(data.F.data)
    defer delete(data.C.data)
    defer delete(data.V.data)

    start := time.now()

    if config.execution_mode == "seq" {
        sequential_convolution(&data)
    } else if config.execution_mode == "par" {
        switch config.strategy {
        case .Horizontal:
            horizontal_convolution(&data, config.num_threads)
        case .Vertical:
            vertical_convolution(&data, config.num_threads)
        case .Block:
            block_convolution(&data, config.num_threads)
        case .Sequential:
            sequential_convolution(&data)
        }
    } else {
        fmt.eprintln("Unknown execution mode:", config.execution_mode)
        os.exit(1)
    }

    duration := time.since(start)
    ms := time.duration_milliseconds(duration)

    write_ok := write_output(&data, "output.txt")
    if !write_ok {
        fmt.eprintln("Error: Could not write output file")
        os.exit(1)
    }

    fmt.printf("Convolution time: %d ms\n", int(ms))
}
