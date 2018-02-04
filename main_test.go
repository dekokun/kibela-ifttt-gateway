package main

import (
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
		mockIftttClient.EXPECT().Trigger("hogefuga", []string{"a", "a"}).Return(nil)
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
