package controllers

import (
	"errors"
	"net/http"
	"net/url"
	"strings"
)

// SendCellularSMS is a func
func SendCellularSMS(mobileNO, message string) error {

	accountSid := "AC5ec2c719f863d53c9f8500c92b4dfca8"
	authToken := "ee1c06352931e7e3b4f8c8e61c08e2ea"

	urlStr := "https://api.twilio.com/2010-04-01/Accounts/" + accountSid + "/Messages.json"

	v := url.Values{}
	v.Set("To", mobileNO)
	v.Set("From", "+19382014765")
	v.Set("Body", message)
	rb := *strings.NewReader(v.Encode())

	client := &http.Client{}

	req, _ := http.NewRequest("POST", urlStr, &rb)
	req.SetBasicAuth(accountSid, authToken)
	req.Header.Add("Accept", "application/json")
	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")

	resp, _ := client.Do(req)
	if resp.StatusCode == http.StatusCreated {
		return nil
	}

	err := errors.New("cannot send message to given number or number is invalid")
	return err
}
