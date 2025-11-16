CC = gcc
CFLAGS = -Wall -O2 -pthread -I./src
LDFLAGS = -lrt -lpthread

SRC = src/main.c src/list.c src/data_generator.c src/thread_safe_list.c \
      src/queue.c src/sequential.c src/parallel.c

all: benchmark

benchmark: $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o benchmark $(LDFLAGS)

clean:
	rm -f benchmark sequential
	rm -rf data
	rm -f *.txt

run: benchmark
	./benchmark

.PHONY: all clean run
