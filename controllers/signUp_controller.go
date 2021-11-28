package controllers

import (
	"api/auth"
	"api/database"
	"api/models"
	"api/repository"
	"api/repository/crud"
	"api/responses"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"math/rand"
	"net/http"
	"strconv"
	"time"

	"github.com/badoux/checkmail"
)

type tempUser struct {
	ID        uint32    `json:"id"`
	UserName  string    `json:"username"`
	Email     string    `json:"email"`
	Password  string    `json:"password"`
	CreatedAt time.Time `json:"created_at"`
	LastLogin time.Time `json:"last_login"`
	LoginType string    `json:"login_type"`
	TypeLogin string    `json:"type_login"`
	OTP       string    `json:"otp"`
}

//SignUp is func
func SignUp(w http.ResponseWriter, r *http.Request) {
	loginresponse := LoginResponse{}
	tempuser := tempUser{}
	user := models.User{}

	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	err = json.Unmarshal(body, &tempuser)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		fmt.Println("in the unmarshal error")
		return
	}
	dummyUser := user
	dummyUser.Email = tempuser.Email
	foundUser := findEmail(dummyUser)
	if foundUser.ID == 0 {
		if tempuser.OTP == "" {
			OTP(tempuser.Email, w, "Verification Code for Study")
			return
		}

		if tempuser.LoginType != "student" && tempuser.LoginType != "faculty" {
			var LoginTypeErr error = errors.New("enter valid login type")
			responses.ERROR(w, http.StatusInternalServerError, LoginTypeErr)
			return
		}

		tempotp := models.TempOTP{Email: tempuser.Email, OTP: tempuser.OTP}
		user.Email = tempuser.Email
		user.Password = tempuser.Password
		user.LoginType = tempuser.LoginType

		if user.LoginType != "student" && user.LoginType != "faculty" {
			var LoginTypeErr error = errors.New("not a valid Login You loggedIn as " + user.LoginType + " you should login as student or faculty")
			responses.ERROR(w, http.StatusNotAcceptable, LoginTypeErr)
			return
		}

		if !VerifyOTP(tempotp) {
			var err1 error = errors.New("Not a valid otp for " + tempuser.Email + " you have entered " + tempuser.OTP)
			responses.ERROR(w, http.StatusNotAcceptable, err1)
			return
		}
		DeleteTemp(tempotp.Email, tempotp)

		user.Prepare()
		if err := checkmail.ValidateFormat(user.Email); err == nil {

			rand.Seed(time.Now().UnixNano())
			user.UserName = user.Email[0:f(user.Email)] + strconv.Itoa(rand.Intn(2000))
			user.LastLogin = time.Now()
			user.CreatedAt = time.Now()

			// db, err := database.Connect()
			// if err != nil {
			// 	responses.ERROR(w, http.StatusInternalServerError, err)
			// 	return
			// }
			// defer db.Close()

			repo := crud.NewRepositoryUsersCRUD(database.DB)

			func(usersRepository repository.UserRepository) {
				user, err = usersRepository.Save(user)
				if err != nil {
					responses.ERROR(w, http.StatusUnprocessableEntity, err)
					return
				}
				w.Header().Set("Location", fmt.Sprintf("%s%s/%d", r.Host, r.RequestURI, user.ID))
			}(repo)

			token, err := auth.CreateToken(user.ID)
			if err != nil {
				responses.ERROR(w, http.StatusUnprocessableEntity, err)
				return
			}

			loginresponse.Identity = user.ID
			loginresponse.Email = user.Email
			loginresponse.UserName = user.UserName
			loginresponse.Token = token
			loginresponse.CreatedAt = user.CreatedAt
			loginresponse.LastLogin = user.LastLogin
			loginresponse.LoginType = user.LoginType

			responses.JSON(w, http.StatusOK, loginresponse)
		} else {
			var err1 error = errors.New("email formate not correct")
			responses.ERROR(w, http.StatusNotAcceptable, err1)
			return
		}

	} else {
		var LoginTypeErr error = errors.New("you have already signedin please signin to continue or signup with different emailid")
		responses.ERROR(w, http.StatusNotAcceptable, LoginTypeErr)
		return
	}

}

// VerifyOTP is a func
func VerifyOTP(tempuser models.TempOTP) bool {
	tempotp, err := GetTempOTP(tempuser)
	if err != nil {
		return false
	}
	fmt.Println("otp stored in db is ", tempotp.OTP)
	fmt.Println("otp from request in is ", tempuser.OTP)
	return tempotp.OTP == tempuser.OTP
}

func f(email string) int {
	for i := range email {
		if string(email[i]) == "@" {
			return i
		}
	}
	if len(email) >= 10 {
		return 10
	}
	return len(email)
}
