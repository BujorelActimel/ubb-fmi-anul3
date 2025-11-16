CC = gcc
CFLAGS = -Wall -O2
LDFLAGS = -lrt

all: sequential

sequential: src/main.c src/list.c
	$(CC) $(CFLAGS) src/main.c -o sequential $(LDFLAGS)

clean:
	rm -f sequential
	rm -rf data
	rm -f rezultate.txt

generate:
	python3 generate_data.py

test: generate sequential
	./sequential
	@echo "\nResultate salvate in rezultate.txt"
	@echo "Primele 10 linii din rezultate.txt:"
	@head -10 rezultate.txt

.PHONY: all clean generate test
