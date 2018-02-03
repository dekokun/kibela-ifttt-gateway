package main

import (
	"errors"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/lorenzobenvenuti/ifttt"
)

var (
	// ErrNameNotProvided is thrown when a name is not provided
	ErrNameNotProvided = errors.New("no data was provided in the HTTP body")
)

func handleRequest(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// If no data is provided in the HTTP request body, throw an error
	if len(request.Body) < 1 {
		return events.APIGatewayProxyResponse{}, ErrNameNotProvided
	}
	responseBody, err := handleBody(request.Body)
	return makeResponse(responseBody, err), err
}

func handleBody(body string) (string, error) {
	iftttClient := ifttt.NewIftttClient("hogefuga")
	values := []string{"firstValue", "secondValue"}
	iftttClient.Trigger("hogefuga", values)

	responceBody := "Hello, " + body
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
