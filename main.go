package main

import (
	"context"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

func main() {
	if len(os.Args) != 2 {
		printAndExit("You must pass in one argument")
	}
	variableName := os.Args[1]
	bucketName := strings.Split(variableName, "/")[0]
	keyName := strings.Join(strings.Split(variableName, "/")[1:], "/")

	cfg, err := config.LoadDefaultConfig(context.Background())
	if err != nil {
		printAndExit(fmt.Sprintf("%v %v", err.Error(), variableName))
	}

	svc := s3.NewFromConfig(cfg)

	// make sure bucket exists
	_, err = svc.HeadBucket(context.TODO(), &s3.HeadBucketInput{
		Bucket: &bucketName,
	})
	if err != nil {
		printAndExit(fmt.Sprintf("%v %v", err.Error(), variableName))
	}

	getParams := &s3.GetObjectInput{
		Bucket: &bucketName,
		Key:    &keyName,
	}

	resp, err := svc.GetObject(context.Background(), getParams)
	if err != nil {
		printAndExit(fmt.Sprintf("%v %v", err.Error(), variableName))
	}

	defer resp.Body.Close()
	contents, err := io.ReadAll(resp.Body)
	if err != nil {
		printAndExit(err.Error())
	}

	fmt.Print(string(contents))

}

func printAndExit(err string) {
	os.Stderr.Write([]byte(err))
	os.Exit(1)
}
