BUILD := build/lambda-go
OUTPUT_TEMPLATE := output.yml
INPUT_TEMPATE := template.yml
VERSIONFILE := version.go

DEP := .bin/dep
GOBUMP := .bin/gobump

.PHONY: deploy
deploy: $(OUTPUT_TEMPLATE)
	aws cloudformation deploy \
		--template-file $(OUTPUT_TEMPLATE) \
		--stack-name kibela-cloudformation \
		--capabilities CAPABILITY_IAM

$(BUILD): main.go Makefile $(VERSIONFILE)
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

$(VERSIONFILE): main.go $(GOBUMP)
	./.bin/gobump patch -w -v

.PHONY: test
test:
	go test
