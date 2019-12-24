.PHONY: build clean deploy

GOBIN := $(shell go env GOPATH)/bin

all: build fix vet fmt lint sec tidy

build:
	export GO111MODULE=on
	env GOOS=linux go build -ldflags="-s -w" -o bin/usn-api src/main.go

clean:
	rm -rf ./bin ./vendor Gopkg.lock

deploy: clean build
	sls deploy --stage dev --verbose

deployprod: clean build
	sls deploy --stage prod --verbose

fix:
	go fix ./...

fmt:
	go fmt ./...

lint:
	(which $(GOBIN)/golangci-lint || go get github.com/golangci/golangci-lint/cmd/golangci-lint@v1.21.0)
	$(GOBIN)/golangci-lint run ./...

sec:
	(which $(GOBIN)/gosec || go get github.com/securego/gosec/cmd/gosec)
	$(GOBIN)/gosec ./...

tidy:
	go mod tidy

vet:
	go vet ./...
