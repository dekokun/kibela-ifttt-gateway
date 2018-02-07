package main

type iftttmock struct {
}

func (iftttmock) Trigger(event string, values []string) error {
	return nil
}
