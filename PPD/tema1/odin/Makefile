ODIN = odin
BUILD_DIR = build
TARGET = $(BUILD_DIR)/convolution
SRC = main.odin

all: $(BUILD_DIR) $(TARGET)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(TARGET): $(SRC)
	$(ODIN) build . -out:$(TARGET) -o:speed

clean:
	rm -rf $(BUILD_DIR) output.txt

test: $(TARGET)
	@echo "Running test with 100x100 matrix..."
	python3 ../generate-input.py 100 100 5 test_input.txt
	./$(TARGET) -i test_input.txt -e seq
	@echo "Sequential test completed."
	./$(TARGET) -i test_input.txt -e par -t 4 -s horizontal
	@echo "Parallel horizontal test completed."
	rm -f test_input.txt output.txt

.PHONY: all clean test
