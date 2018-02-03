package main

import "testing"

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

	actual, err := handleRequestBody(reqBody)
	if err != nil {
		t.Errorf("got err %v\n", err)
	}

	expected := ""
	if actual != expected {
		t.Errorf("got %v\nwant %v", actual, expected)
	}
}
