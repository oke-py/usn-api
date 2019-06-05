package main

import (
	"bytes"
	"context"
	"encoding/json"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/guregu/dynamo"
)

// Response is of type APIGatewayProxyResponse since we're leveraging the
// AWS Lambda Proxy Request functionality (default behavior)
//
// https://serverless.com/framework/docs/providers/aws/events/apigateway/#lambda-proxy-integration
type Response events.APIGatewayProxyResponse

type Notice struct {
	ID        string `dynamo:"usn_id"`
	Pkg       string `dynamo:"name"`
	CVEs      []string
	Priority  string    `dynamo:"severity"`
	Published time.Time `dynamo:"published"`
	Updated   time.Time `dynamo:"updated"`
}

// Handler is our lambda handler invoked by the `lambda.Start` function call
func Handler(ctx context.Context) (Response, error) {
	db := dynamo.New(session.New(), &aws.Config{Region: aws.String("ap-northeast-1")})
	table := db.Table("usn")

	var notices []Notice
	err := table.Scan().All(&notices)
	if err != nil {
		return Response{StatusCode: 500}, err
	}

	var buf bytes.Buffer

	body, err := json.Marshal(notices)
	if err != nil {
		return Response{StatusCode: 404}, err
	}
	json.HTMLEscape(&buf, body)

	resp := Response{
		StatusCode:      200,
		IsBase64Encoded: false,
		Body:            buf.String(),
		Headers: map[string]string{
			"Content-Type":                "application/json",
			"Access-Control-Allow-Origin": "https://oke-py.github.io",
		},
	}

	return resp, nil
}

func main() {
	lambda.Start(Handler)
}
