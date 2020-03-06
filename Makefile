# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: fsc android ios fsc-cross evm all test clean
.PHONY: fsc-linux fsc-linux-386 fsc-linux-amd64 fsc-linux-mips64 fsc-linux-mips64le
.PHONY: fsc-linux-arm fsc-linux-arm-5 fsc-linux-arm-6 fsc-linux-arm-7 fsc-linux-arm64
.PHONY: fsc-darwin fsc-darwin-386 fsc-darwin-amd64
.PHONY: fsc-windows fsc-windows-386 fsc-windows-amd64

GOBIN = ./build/bin
GO ?= latest
GORUN = env GO111MODULE=on go run

fsc:
	$(GORUN) build/ci.go install ./cmd/fsc
	@echo "Done building."
	@echo "Run \"$(GOBIN)/fsc\" to launch fsc."

all:
	$(GORUN) build/ci.go install

android:
	$(GORUN) build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/fsc.aar\" to use the library."

ios:
	$(GORUN) build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/fsc.framework\" to use the library."

test: all
	$(GORUN) build/ci.go test

lint: ## Run linters.
	$(GORUN) build/ci.go lint

clean:
	env GO111MODULE=on go clean -cache
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/kevinburke/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go get -u github.com/golang/protobuf/protoc-gen-go
	env GOBIN= go install ./cmd/abigen
	@type "npm" 2> /dev/null || echo 'Please install node.js and npm'
	@type "solc" 2> /dev/null || echo 'Please install solc'
	@type "protoc" 2> /dev/null || echo 'Please install protoc'

# Cross Compilation Targets (xgo)

fsc-cross: fsc-linux fsc-darwin fsc-windows fsc-android fsc-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/fsc-*

fsc-linux: fsc-linux-386 fsc-linux-amd64 fsc-linux-arm fsc-linux-mips64 fsc-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/fsc-linux-*

fsc-linux-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/fsc
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/fsc-linux-* | grep 386

fsc-linux-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/fsc
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/fsc-linux-* | grep amd64

fsc-linux-arm: fsc-linux-arm-5 fsc-linux-arm-6 fsc-linux-arm-7 fsc-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/fsc-linux-* | grep arm

fsc-linux-arm-5:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/fsc
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/fsc-linux-* | grep arm-5

fsc-linux-arm-6:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/fsc
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/fsc-linux-* | grep arm-6

fsc-linux-arm-7:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/fsc
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/fsc-linux-* | grep arm-7

fsc-linux-arm64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/fsc
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/fsc-linux-* | grep arm64

fsc-linux-mips:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/fsc
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/fsc-linux-* | grep mips

fsc-linux-mipsle:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/fsc
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/fsc-linux-* | grep mipsle

fsc-linux-mips64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/fsc
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/fsc-linux-* | grep mips64

fsc-linux-mips64le:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/fsc
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/fsc-linux-* | grep mips64le

fsc-darwin: fsc-darwin-386 fsc-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/fsc-darwin-*

fsc-darwin-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/fsc
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/fsc-darwin-* | grep 386

fsc-darwin-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/fsc
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/fsc-darwin-* | grep amd64

fsc-windows: fsc-windows-386 fsc-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/fsc-windows-*

fsc-windows-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/fsc
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/fsc-windows-* | grep 386

fsc-windows-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/fsc
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/fsc-windows-* | grep amd64
