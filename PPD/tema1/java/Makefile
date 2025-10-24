JAVAC = javac
BUILD_DIR = build

SOURCES = Convolution.java ConvolutionStrategy.java SequentialStrategy.java HorizontalStrategy.java VerticalStrategy.java BlockStrategy.java

all: $(BUILD_DIR) compile

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

compile: $(SOURCES)
	$(JAVAC) -d $(BUILD_DIR) $(SOURCES)
	@echo ""
	@echo "Java build successful!"

clean:
	rm -rf $(BUILD_DIR) output.txt

.PHONY: all compile 
