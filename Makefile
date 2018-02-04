BUILD := build/lambda-go
OUTPUT_TEMPLATE := output.yml
INPUT_TEMPATE := template.yml
VERSIONFILE := ./version.go
MAINFILE := ./main.go
MOCK_IFTTT := mock_ifttt_test.go

DEP := .bin/dep
GOBUMP := .bin/gobump
MOCKGEN := .bin/mockgen

.PHONY: deploy
deploy: $(OUTPUT_TEMPLATE)
	aws cloudformation deploy \
		--template-file $(OUTPUT_TEMPLATE) \
		--stack-name kibela-cloudformation \
		--capabilities CAPABILITY_IAM

$(BUILD): $(MAINFILE) Makefile $(VERSIONFILE) config.toml
	GOARCH=amd64 GOOS=linux go build -o $(BUILD)

$(OUTPUT_TEMPLATE): $(INPUT_TEMPATE) $(BUILD)
	aws cloudformation package \
		--template-file $(INPUT_TEMPATE) \
		--s3-bucket dekokun-alexa-example \
		--s3-prefix lambda-go \
		--output-template-file $(OUTPUT_TEMPLATE)

.PHONY: setup-go
setup-go:
	GOBIN=$(abspath .bin) go get -v \
		github.com/golang/dep/cmd/dep \
		github.com/golang/mock/gomock \
		github.com/golang/mock/mockgen \
		github.com/motemen/gobump/cmd/gobump

.bin/%: Makefile
	@$(MAKE) setup-go
	@touch $@

$(VERSIONFILE): $(MAINFILE) $(GOBUMP)
	./.bin/gobump patch -w -v

.PHONY: install
install: $(DEP) -v -covermode=count -coverprofile=coverage.out
	$(DEP) ensure

.PHONY: test
test: $(MOCK_IFTTT)
	go test

config.toml:
	cp config.toml.sample config.toml
	@echo "\033[92mplease edit config.toml \033[0m"
	@exit 1

$(MOCK_IFTTT): $(MOCKGEN) vendor/github.com/lorenzobenvenuti/ifttt/ifttt.go
	$(MOCKGEN) -package main -source vendor/github.com/lorenzobenvenuti/ifttt/ifttt.go > $(MOCK_IFTTT)
