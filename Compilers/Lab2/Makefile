.PHONY: all build-cli build-wasm run-cli serve test clean

all: build-cli build-wasm

build-cli:
	@echo "Building CLI..."
	@mkdir -p bin
	cd core && go build -tags !wasm -o ../bin/fa-cli
	@echo "CLI built successfully: bin/fa-cli"

build-wasm:
	@echo "Building WASM..."
	@mkdir -p web
	cd core && GOOS=js GOARCH=wasm go build -tags wasm -o ../web/core.wasm
	@cp "$$(go env GOROOT)/lib/wasm/wasm_exec.js" web/ 2>/dev/null || cp "$$(go env GOROOT)/misc/wasm/wasm_exec.js" web/
	@echo "WASM built successfully: web/core.wasm"

run-cli:
	@go run -tags !wasm core/*.go

serve:
	@echo "Starting web server at http://localhost:8080"
	@cd web && python3 -m http.server 8080

test:
	@go test -v ./core/...

clean:
	@rm -rf bin/ web/core.wasm web/wasm_exec.js
	@echo "Cleaned build artifacts"
