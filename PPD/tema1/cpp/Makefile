CXX = g++
CXXFLAGS = -std=c++11 -O2 -Wall -pthread

BUILD_DIR = build
SRC_DIR = .

TARGET = $(BUILD_DIR)/convolution
SRCS = main.cpp convolution_static.cpp convolution_vector.cpp
OBJS = $(addprefix $(BUILD_DIR)/, $(SRCS:.cpp=.o))

all: $(BUILD_DIR) $(TARGET)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS)
	@echo ""
	@echo "Build successful! Executable: $(TARGET)"

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp convolution.h | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR) output.txt

test: $(TARGET)
	@echo "Running quick test..."
	python3 generate-input.py 100 100 3 test.txt
	@echo "\n=== Sequential (vector) ==="
	$(TARGET) -i test.txt -m vector -e seq
	@echo "\n=== Parallel 4 threads (vector, horizontal) ==="
	$(TARGET) -i test.txt -m vector -e par -t 4 -s horizontal
	@echo "\n=== Parallel 4 threads (static, vertical) ==="
	$(TARGET) -i test.txt -m static -e par -t 4 -s vertical

help:
	@echo "Makefile targets:"
	@echo "  make          - Build the project"
	@echo "  make clean    - Remove build directory and output files"
	@echo "  make test     - Run quick tests"
	@echo "  make help     - Show this help"

.PHONY: all clean test help