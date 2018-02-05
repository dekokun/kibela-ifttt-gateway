BUILD := build/lambda-go
OUTPUT_TEMPLATE := output.yml
INPUT_TEMPATE := template.yml
VERSIONFILE := ./version.go
MAINFILE := ./main.go
MOCK_IFTTT := mock_ifttt_test.go

DEP := .bin/dep
GOBUMP := .bin/gobump
MOCKGEN := .bin/mockgen
SAMLOCAL := .bin/aws-sam-local

.PHONY: deploy
deploy: $(OUTPUT_TEMPLATE)
	aws cloudformation deploy \
		--template-file $< \
		--stack-name kibela-cloudformation \
		--capabilities CAPABILITY_IAM

$(BUILD): $(MAINFILE) Makefile $(VERSIONFILE) config.toml
	GOARCH=amd64 GOOS=linux go build -o $@
	cp config.toml build/config.toml

$(OUTPUT_TEMPLATE): $(INPUT_TEMPATE) $(BUILD)
	aws cloudformation package \
		--template-file $< \
		--s3-bucket dekokun-alexa-example \
		--s3-prefix lambda-go \
		--output-template-file $@

.PHONY: setup-go
setup-go:
	GOBIN=$(abspath .bin) go get -v \
		github.com/golang/dep/cmd/dep \
		github.com/golang/mock/gomock \
		github.com/golang/mock/mockgen \
		github.com/motemen/gobump/cmd/gobump \
		github.com/awslabs/aws-sam-local

.bin/%: Makefile
	@$(MAKE) setup-go
	@touch $@

$(VERSIONFILE): $(MAINFILE) $(GOBUMP)
	./.bin/gobump patch -w -v

.PHONY: install
install: $(DEP)
	$(DEP) ensure

.PHONY: test
test: $(MOCK_IFTTT) config.toml $(SAMLOCAL)
	go test -v -covermode=count -coverprofile=coverage.out

coverage.html: test
	go tool cover -html=coverage.out -o $@

config.toml:
	cp -n config.toml.sample config.toml
	@echo "\033[92mplease edit config.toml \033[0m"

$(MOCK_IFTTT): $(MOCKGEN) vendor/github.com/lorenzobenvenuti/ifttt/ifttt.go
	$(MOCKGEN) -package main -source vendor/github.com/lorenzobenvenuti/ifttt/ifttt.go > $@
