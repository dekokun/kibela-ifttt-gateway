# kibela-ifttt-gateway
kibela - ifttt webhook via AWS AMazon api gateway

[![Build Status](https://travis-ci.org/dekokun/kibela-ifttt-gateway.svg?branch=master)](https://travis-ci.org/dekokun/kibela-ifttt-gateway)[![Go Report Card](https://goreportcard.com/badge/github.com/dekokun/kibela-ifttt-gateway)](https://goreportcard.com/report/github.com/dekokun/kibela-ifttt-gateway)[![Coverage Status](https://coveralls.io/repos/github/dekokun/kibela-ifttt-gateway/badge.svg?branch=master)](https://coveralls.io/github/dekokun/kibela-ifttt-gateway?branch=master)[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)


## Setup

### Pre-requisites

- Register for an [AWS ACCOUNT](https://aws.amazon.com/)
- Install and Setup [AWS CLI](https://aws.amazon.com/cli/)
  - Setup: [AWS account and credentials](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).
- [Install Golang](https://golang.org/doc/install)

### Installation

1. Clone the repository

```
$ git clone https://github.com/dekokun/kibela-ifttt-gateway.git
```

2. Change config file

```bash
$ cd kibela-ifttt-gateway
$ vi config.mk
```

3. Make S3 bucket for lambda deploy

If you already have the bucket, please skip this step.

```bash
$ make setup-s3
```

4. deploy with AWS CloudFormation

```bash
$ make deploy
```

