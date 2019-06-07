.PHONY: build clean deploy gomodgen

build: gomodgen
	export GO111MODULE=on
	env GOOS=linux go build -ldflags="-s -w" -o bin/usn-api src/main.go

clean:
	rm -rf ./bin ./vendor Gopkg.lock

deploy: clean build
	sls deploy --stage dev --table usn-dev --verbose

deployprod: clean build
	sls deploy --stage prod --table usn --verbose

gomodgen:
	chmod u+x gomod.sh
	./gomod.sh
