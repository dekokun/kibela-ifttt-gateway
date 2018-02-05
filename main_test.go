package main

import (
	"errors"
	"testing"

	"github.com/golang/mock/gomock"
	"github.com/lorenzobenvenuti/ifttt"
)

func TestHandleBody(t *testing.T) {
	reqBody := `
	{
  "action": "create",
  "action_user": {
    "account": "kibe",
    "avatar_photo": {
      "url": "https://cdn.kibe.la/media/public/1/kibe.png"
    },
    "id": "1",
    "real_name": "kibe-san",
    "url": "https://docs.kibe.la/@kibe"
  },
  "blog": {
    "author": {
      "account": "kibe",
      "avatar_photo": {
        "url": "https://cdn.kibe.la/media/public/1/kibe.png"
      },
      "id": "1",
      "real_name": "kibe-san",
      "url": "https://docs.kibe.la/@kibe"
    },
    "boards": [
      {
        "id": "1",
        "name": "Product Team"
      }
    ],
    "content_html": "<h2>sample request</h2>",
    "content_md": "## sample request",
    "id": "1",
    "title": "sample request",
    "url": "https://docs.kibe.la/@kibe/1"
  },
  "resource_type": "blog",
  "team": {
    "name": "docs",
    "url": "https://docs.kibe.la"
  }
}
	`

	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	// convert ifttt client to mock
	makeIftttClient = func(key string) ifttt.IftttClient {
		mockIftttClient := NewMockIftttClient(ctrl)
		mockIftttClient.EXPECT().Trigger(gomock.Any(), gomock.Any()).Return(nil)
		return mockIftttClient
	}

	actual, err := handleRequestBody(reqBody)
	if err != nil {
		t.Errorf("got err %v\n", err)
	}

	expected := "https://docs.kibe.la/@kibe/1"
	if actual != expected {
		t.Errorf("got %v\nwant %v", actual, expected)
	}
}

func TestHandleBodyInvalidJson(t *testing.T) {
	reqBody := `
	Hogefuga
	`

	_, err := handleRequestBody(reqBody)
	if err == nil {
		t.Errorf("not got err %v\n", err)
	}
}

func TestMakeResponse(t *testing.T) {

	body := "body"
	actual := makeResponse(body, nil)
	expected := 200
	if actual.StatusCode != expected {
		t.Errorf("got %v\nwant %v", actual.StatusCode, expected)
	}
	expectedBody := body
	if actual.Body != expectedBody {
		t.Errorf("got %v\nwant %v", actual.Body, expectedBody)
	}
}

func TestMakeResponseErr(t *testing.T) {

	body := "body"
	err := errors.New("error")
	actual := makeResponse(body, err)
	expected := 504
	if actual.StatusCode != expected {
		t.Errorf("got %v\nwant %v", actual.StatusCode, expected)
	}
}
