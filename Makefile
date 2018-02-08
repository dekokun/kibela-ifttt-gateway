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
deploy: $(OUTPUT_TEMPLATE) $(SAMLOCAL) $(BUILD)
	$(SAMLOCAL) deploy \
		--template-file $< \
		--stack-name kibela-cloudformation \
		--capabilities CAPABILITY_IAM

$(BUILD): $(MAINFILE) $(VERSIONFILE) Makefile config.toml
	$(MAKE) install
	GOARCH=amd64 GOOS=linux go build -o $@
	cp config.toml build/config.toml

$(OUTPUT_TEMPLATE): $(INPUT_TEMPATE) $(BUILD) $(SAMLOCAL)
	$(SAMLOCAL) package \
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
	go test -covermode=count -coverprofile=coverage.out

coverage.html: test
	go tool cover -html=coverage.out -o $@

config.toml:
	cp -n config.toml.sample config.toml
	@echo "\033[92mplease edit config.toml \033[0m"

$(MOCK_IFTTT): $(MOCKGEN) vendor/github.com/lorenzobenvenuti/ifttt/ifttt.go
	$(MOCKGEN) -package main -source vendor/github.com/lorenzobenvenuti/ifttt/ifttt.go > $@

.PHONY: start_server
start_server: $(BUILD) $(SAMLOCAL)
	$(SAMLOCAL) local start-api

.PHONY: integration_test
integration_test:
	$(MAKE) start_server &
	curl -XPOST http://localhost:3000/payload -d '{"team":{"name":"dekokun","url":"https://dekokun.kibe.la/"},"blog":{"id":20,"url":"https://dekokun.kibe.la/@dekokun/20","title":"このLINE通知が来たら何か おかしい！？dekokunに連絡だ！","boards":[{"id":1,"name":"Home"}],"author":{"id":2,"account":"dekokun","real_name":"","url":"https://dekokun.kibe.la/@dekokun","avatar_photo":{"url":"https://cdn.kibe.la/media/public/1633/W1siZiIsInRlYW1fMTYzMy8yMDE3LzAzLzMxLzRrYTNkdGE0aHNfZ3JhdmF0YXJfMjIweDIyMC5wbmciXSxbInAiLCJlbmNvZGUiLCJwbmciXSxbInAiLCJjb252ZXJ0IiwiLWFscGhhIHNldCAtYmFja2dyb3VuZCBub25lIC12aWduZXR0ZSAweDArMCswIl0sWyJwIiwidGh1bWIiLCI0MHg0MCJdXQ/89f0f820ea4bcc6e/file.png"}},"comments":[]},"resource_type":"blog","action":"delete","action_user":{"id":2,"account":"dekokun","real_name":"","url":"https://dekokun.kibe.la/@dekokun","avatar_photo":{"url":"https://cdn.kibe.la/media/public/1633/W1siZiIsInRlYW1fMTYzMy8yMDE3LzAzLzMxLzRrYTNkdGE0aHNfZ3JhdmF0YXJfMjIweDIyMC5wbmciXSxbInAiLCJlbmNvZGUiLCJwbmciXSxbInAiLCJjb252ZXJ0IiwiLWFscGhhIHNldCAtYmFja2dyb3VuZCBub25lIC12aWduZXR0ZSAweDArMCswIl0sWyJwIiwidGh1bWIiLCI0MHg0MCJdXQ/89f0f820ea4bcc6e/file.png"}}}' --dump-header -
