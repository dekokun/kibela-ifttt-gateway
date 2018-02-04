package main

import (
	"encoding/json"
	"errors"
	"log"

	"github.com/BurntSushi/toml"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	dproxy "github.com/koron/go-dproxy"
	"github.com/lorenzobenvenuti/ifttt"
)

var (
	// ErrNameNotProvided is thrown when a name is not provided
	ErrNameNotProvided = errors.New("no data was provided in the HTTP body")
	makeIftttClient    = ifttt.NewIftttClient
)

func handleRequest(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// If no data is provided in the HTTP request body, throw an error
	if len(request.Body) < 1 {
		return events.APIGatewayProxyResponse{}, ErrNameNotProvided
	}
	responseBody, err := handleRequestBody(request.Body)
	return makeResponse(responseBody, err), err
}

func handleRequestBody(body string) (string, error) {
	// var data struct {
	// 	action      string      `json:"action"`
	// 	action_user interface{} `json:"action_user"`
	// 	blog        struct {
	// 		author    interface{}
	// 		id        float64
	// 		real_name string
	// 		url       string
	// 	} `json:"blog"`
	// 	resource_type string      `json:"resource_type"`
	// 	team          interface{} `json:"team"`
	// }
	var data interface{}
	bodyByte := []byte(body)
	if err := json.Unmarshal(bodyByte, &data); err != nil {
		log.Print("JSON Unmarshal error:", err)
		return "JSON decode error", err
	}

	url, err := dproxy.New(data).M("blog").M("url").String()

	if err != nil {
		log.Print("json responce is unexpected:", err)
		return "json responce is unexpected", err
	}

	iftttClient := makeIftttClient(loadConfig().IftttKey)
	values := []string{"a", "a"}
	iftttClient.Trigger("hogefuga", values)

	// responceBody := data.blog.url
	responceBody := url
	return responceBody, nil
}

func makeResponse(body string, err error) events.APIGatewayProxyResponse {
	status := 200
	if err != nil {
		status = 504
	}
	return events.APIGatewayProxyResponse{
		Body:       body,
		StatusCode: status,
		Headers:    map[string]string{"version": version},
	}
}

func main() {
	lambda.Start(handleRequest)
}

type config struct {
	IftttKey string
}

func loadConfig() config {
	var configToml config
	_, err := toml.DecodeFile("config.toml", &configToml)
	if err != nil {
		panic(err)
	}
	return configToml
}
