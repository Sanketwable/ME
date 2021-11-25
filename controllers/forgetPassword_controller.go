package controllers

import (
	"api/auth"
	"api/database"
	"api/models"
	"api/responses"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"
)

// ForgotPasswordResponse is a struct
type ForgotPasswordResponse struct {
	Email     string    `json:"email"`
	Message   string    `json:"message"`
	Token     string    `json:"token"`
	UpdatedAt time.Time `json:"update_at"`
}

// ForgotPasswordRequest is a struct
type ForgotPasswordRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
	OTP      string `json:"otp"`
}

// ForgetPassword is a func
func ForgetPassword(w http.ResponseWriter, r *http.Request) {

	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	req := ForgotPasswordRequest{}
	err = json.Unmarshal(body, &req)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	fmt.Println(req)

	ltype, uid := EmailPresent(req)
	if ltype == "student" {
		var err1 error = errors.New("no user Found coresponding to email provided")
		responses.ERROR(w, http.StatusNotAcceptable, err1)
		return
	}
	if req.OTP == "" {
		OTP(req.Email, w, "OTP to reset your password")
		return
	}
	tempotp := models.TempOTP{}
	tempotp.Email = req.Email
	tempotp.OTP = req.OTP

	if !VerifyOTP(tempotp) {
		fmt.Println("NOT Verified")
		var err1 error = errors.New("Not a valid otp for " + req.Email + " you have entered " + req.OTP)
		responses.ERROR(w, http.StatusNotAcceptable, err1)
		return
	}
	DeleteTemp(tempotp.Email, tempotp)
	UpdateForgettedPassword(req.Email, req.Password, uid, w)

	token, err := auth.CreateToken(uid)
	if err != nil {
		var err1 error = errors.New("cannot generate token")
		responses.ERROR(w, http.StatusUnprocessableEntity, err1)
		return
	}
	fpr := ForgotPasswordResponse{}
	fpr.Token = token
	fpr.Email = req.Email
	fpr.Message = "Updated Password"
	fpr.UpdatedAt = time.Now()

	responses.JSON(w, http.StatusOK, fpr)

}

// EmailPresent is a func
func EmailPresent(req ForgotPasswordRequest) (string, uint32) {
	dummyuser := models.User{}
	dummyuser.Email = req.Email
	var err error
	// db, _ := database.Connect()
	// defer db.Close()
	err = database.DB.Debug().Model(models.User{}).Where("email = ?", dummyuser.Email).Take(&dummyuser).Error
	if err != nil {
		return "", 0
	}
	fmt.Println("logintype : ", dummyuser.LoginType)
	fmt.Println("ID : ", dummyuser.ID)
	return dummyuser.LoginType, dummyuser.ID
}
