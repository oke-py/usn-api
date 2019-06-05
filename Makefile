.PHONY: build clean deploy gomodgen

build: gomodgen
	export GO111MODULE=on
	env GOOS=linux go build -ldflags="-s -w" -o bin/usn-api src/main.go

clean:
	rm -rf ./bin ./vendor Gopkg.lock

deploy: clean build
	sls deploy --verbose

deployprod: clean build
	sls deploy --stage prod --verbose

gomodgen:
	chmod u+x gomod.sh
	./gomod.sh
