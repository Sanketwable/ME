package controllers

import (
	"api/models"
	"api/responses"
	"errors"
	"fmt"
	"math/rand"
	"net/http"
	"strconv"
	"time"
)

// OTPRequest is a struct
type OTPRequest struct{
	Email     string    `json:"email"`
}
// OTPResponse is a struct
type OTPResponse struct {
	Message string `json:"message"`
	ExpiresAt time.Time `json:"expires_at"`
}

//OTP is a func
func OTP(email string, w http.ResponseWriter, Emailsub string) {
	otprequest := OTPRequest{}
	otprequest.Email = email
	otpresponse := OTPResponse{}

	dummyuser := models.User{}
	dummyuser.Email = otprequest.Email

	if Emailsub == "Verification Code for Study App" {
		u := findEmail(dummyuser)
		if u.ID != 0 {
			var err1 error = errors.New("email is already present in the database, signup with different email")
			responses.ERROR(w, http.StatusNotAcceptable, err1)
			return
		}
	}
 
	rand.Seed(time.Now().UnixNano())
	otp := strconv.Itoa(rand.Intn(10)) + strconv.Itoa(rand.Intn(10)) + strconv.Itoa(rand.Intn(10)) + strconv.Itoa(rand.Intn(10)) + strconv.Itoa(rand.Intn(10)) + strconv.Itoa(rand.Intn(10))

	err := SendOTPEmail(otprequest.Email, otp, Emailsub)
	if err != nil {
		fmt.Println("error of OTP send mail is :", err)
		var err1 error = err
		responses.ERROR(w, http.StatusNotAcceptable, err1)
		return
	}

	fmt.Println("otp send")
	tempotp := models.TempOTP{}
	tempotp.Email = otprequest.Email
	tempotp.OTP = otp
	tempotp.CreatedAt = time.Now()
	tempotp.ExpiresAt = tempotp.CreatedAt.Add(50*time.Minute)
	
	otpresponse.Message = "OTP sent"
	otpresponse.ExpiresAt = tempotp.ExpiresAt
	DeleteTemp(otprequest.Email)
	err = SaveTemp(tempotp)
	if err != nil {
		fmt.Println("error to store otp into DB is : ",err)
		UpdateTemp(tempotp)
	}

	responses.JSON(w, http.StatusCreated, otpresponse)
}



