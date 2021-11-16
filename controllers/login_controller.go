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
	"net/http"
	"time"

	"github.com/badoux/checkmail"
)

// LoginResponse is a response struct
type LoginResponse struct {
	Identity  uint32    `json:"id"`
	Token     string    `json:"token"`
	Email     string    `json:"email"`
	UserName  string    `json:"username"`
	LoginType string    `json:"login_type"`
	CreatedAt time.Time `gorm:"" json:"created_at"`
	LastLogin time.Time `gorm:"" json:"last_login"`
}

//Login is func
func Login(w http.ResponseWriter, r *http.Request) {
	loginresponse := LoginResponse{}
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	user := models.User{}
	err = json.Unmarshal(body, &user)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	if err := checkmail.ValidateFormat(user.Email); err != nil {
		var err1 error = errors.New("email formate not correct")
		responses.ERROR(w, http.StatusNotAcceptable, err1)
		return
	}

	if user.LoginType == "student" || user.LoginType == "faculty" {
		dummyUser := user
		foundUser := findEmail(dummyUser)


		if foundUser.ID == 0 {
			var err1 error = errors.New("not a user")
			responses.ERROR(w, http.StatusNotAcceptable, err1)
			return
		}
		if foundUser.LoginType != user.LoginType {
			var err1 error = errors.New("not a valid loginType")
			responses.ERROR(w, http.StatusNotAcceptable, err1)
			return	
		}
		user.LastLogin = time.Now()

		token, err := auth.SignIn(user.Email, user.Password)
		if err != nil {
			responses.ERROR(w, http.StatusBadRequest, err)
			return
		}

		db, err := database.Connect()
		if err != nil {
			responses.ERROR(w, http.StatusInternalServerError, err)
			return
		}
		defer db.Close()

		repo := crud.NewRepositoryUsersCRUD(db)

		func(userRepository repository.UserRepository) {
			_, err := userRepository.UpdateLastLogin(foundUser.ID, user)
			if err != nil {
				responses.ERROR(w, http.StatusBadRequest, err)
				return
			}
		}(repo)

		loginresponse.Identity = foundUser.ID
		loginresponse.Email = foundUser.Email
		loginresponse.UserName = foundUser.UserName
		loginresponse.Token = token
		loginresponse.LoginType = user.LoginType
		loginresponse.LastLogin = foundUser.LastLogin
		loginresponse.CreatedAt = foundUser.CreatedAt
		responses.JSON(w, http.StatusOK, loginresponse)
		return

	} else {
		var loginTypeErr error = errors.New("enter valid LoginType. Valid LoginTypes are student or faculty")
		responses.ERROR(w, http.StatusNotAcceptable, loginTypeErr)
		return
	}

}

func findEmail(dummyuser models.User) models.User {
	var err error
	db, _ := database.Connect()
	defer db.Close()
	fmt.Println("i am here to find id")
	err = db.Debug().Model(models.User{}).Where("email = ?", dummyuser.Email).Take(&dummyuser).Error
	if err != nil {
		fmt.Println("error is ", err)
		dummyuser.ID = 0
		return dummyuser
	}
	return dummyuser
}


