package controllers

import (
	"api/auth"
	"api/database"
	"api/models"
	"api/repository"
	"api/repository/crud"
	"api/responses"
	"api/security"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
	"strconv"
)

type UserInfo struct {
	Email     string `json:"email"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	UserName  string `json:"user_name"`
	LoginType string `json:"login_type"`
}

//GetUsers is a func
func GetUsers(w http.ResponseWriter, r *http.Request) {
	db, err := database.Connect()
	if err != nil {
		responses.ERROR(w, http.StatusInternalServerError, err)
		return
	}
	defer db.Close()

	repo := crud.NewRepositoryUsersCRUD(db)

	func(usersRepository repository.UserRepository) {
		users, err := usersRepository.FindAll()
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, users)
	}(repo)
}

// //CreateUser is a func
// func CreateUser(w http.ResponseWriter, r *http.Request) {

// 	body, err := ioutil.ReadAll(r.Body)
// 	if err != nil {
// 		responses.ERROR(w, http.StatusUnprocessableEntity, err)
// 		return
// 	}
// 	user := models.User{}
// 	err = json.Unmarshal(body, &user)
// 	if err != nil {
// 		responses.ERROR(w, http.StatusUnprocessableEntity, err)
// 		return
// 	}

// 	user.Prepare()

// 	db, err := database.Connect()
// 	if err != nil {
// 		responses.ERROR(w, http.StatusInternalServerError, err)
// 		return
// 	}
// 	defer db.Close()

// 	repo := crud.NewRepositoryUsersCRUD(db)

// 	func(usersRepository repository.UserRepository) {
// 		user, err = usersRepository.Save(user)
// 		if err != nil {
// 			responses.ERROR(w, http.StatusUnprocessableEntity, err)
// 			return
// 		}
// 		w.Header().Set("Location", fmt.Sprintf("%s%s/%d", r.Host, r.RequestURI, user.ID))
// 		responses.JSON(w, http.StatusCreated, user)
// 	}(repo)

// }

//GetUser is a func
func GetUserInfo(w http.ResponseWriter, r *http.Request) {

	id := r.URL.Query().Get("id")
	user_id, err := strconv.Atoi(id)
	if err != nil {
		responses.ERROR(w, http.StatusBadRequest, err)
		return
	}
	var user models.User
	var userInfo UserInfo

	db, err := database.Connect()
	if err != nil {
		responses.ERROR(w, http.StatusInternalServerError, err)
		return
	}
	defer db.Close()

	repo := crud.NewRepositoryUsersCRUD(db)

	func(usersRepository repository.UserRepository) {
		user, err = usersRepository.FindById(uint32(user_id))
		if err != nil {
			responses.ERROR(w, http.StatusBadRequest, err)
			return
		}

	}(repo)
	userInfo.Email = user.Email
	userInfo.UserName = user.UserName
	userInfo.LoginType = user.LoginType

	if user.LoginType == "student" {
		repo1 := crud.NewRepositoryStudentInfoCRUD(db)

		func(StudentInfoRepository repository.StudentInfoRepository) {
			StudentInfo, err := StudentInfoRepository.FindById(uint64(user_id))
			if err != nil {
				responses.ERROR(w, http.StatusBadRequest, err)
				return
			}
			userInfo.FirstName = StudentInfo.FirstName
			userInfo.LastName = StudentInfo.LastName
		}(repo1)
	} else {
		repo2:= crud.NewRepositoryFacultyInfoCRUD(db)

		func(FacultyInfoRepository repository.FacultyInfoRepository) {
			FacultyInfo, err := FacultyInfoRepository.FindById(uint64(user_id))
			if err != nil {
				responses.ERROR(w, http.StatusBadRequest, err)
				return
			}
			userInfo.FirstName = FacultyInfo.FirstName
			userInfo.LastName = FacultyInfo.LastName
			
		}(repo2)
	}

	responses.JSON(w, http.StatusOK, userInfo)
}

// UpdatedPassword is a struct
type UpdatedPassword struct {
	PreviousPassword string `json:"previous_password"`
	Email            string `json:"email"`
	Password         string `json:"password"`
}

// Response is a struct
type Response struct {
	Message string `json:"message"`
}

//UpdatePassword is a func
func UpdatePassword(w http.ResponseWriter, r *http.Request) {

	up := UpdatedPassword{}

	uid, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}

	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	user := models.User{}
	err = json.Unmarshal(body, &up)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	id, v := ConfirmOldPassword(up.PreviousPassword, up.Email)

	if !v {
		var err1 error = errors.New("old password is incorrect")
		responses.ERROR(w, http.StatusInternalServerError, err1)
		return
	}
	if id != uid {
		var err1 error = errors.New("token not valid")
		responses.ERROR(w, http.StatusInternalServerError, err1)
		return
	}

	hashedPass, err := security.Hash(up.Password)
	if err != nil {
		fmt.Println("error is :", err)
		return
	}
	user.Password = string(hashedPass)

	res := Response{}
	res.Message = "Password Updated"

	db, err := database.Connect()
	if err != nil {
		responses.ERROR(w, http.StatusInternalServerError, err)
		return
	}
	defer db.Close()

	repo := crud.NewRepositoryUsersCRUD(db)

	func(usersRepository repository.UserRepository) {
		_, err := usersRepository.UpdatePassword(uint32(uid), user)
		if err != nil {
			responses.ERROR(w, http.StatusBadRequest, err)
			return
		}

		responses.JSON(w, http.StatusOK, res)
	}(repo)
}

// UpdateForgettedPassword is a func
func UpdateForgettedPassword(email string, password string, uid uint32, w http.ResponseWriter) {

	user := models.User{}
	user.ID = uid
	user.Email = email

	hashedPass, err := security.Hash(password)
	if err != nil {
		fmt.Println("error is :", err)
		return
	}
	user.Password = string(hashedPass)

	db, err := database.Connect()
	if err != nil {
		responses.ERROR(w, http.StatusInternalServerError, err)
		return
	}
	defer db.Close()

	repo := crud.NewRepositoryUsersCRUD(db)

	func(usersRepository repository.UserRepository) {
		_, err := usersRepository.UpdatePassword(uint32(uid), user)
		if err != nil {
			responses.ERROR(w, http.StatusBadRequest, err)
			return
		}
	}(repo)
}

//DeleteUser is a func
func DeleteUser(w http.ResponseWriter, r *http.Request) {
	email := r.URL.Query().Get("email")

	db, err := database.Connect()
	if err != nil {
		responses.ERROR(w, http.StatusInternalServerError, err)
		return
	}
	defer db.Close()

	err = db.Debug().Model(models.User{}).Where("email = ?", email).Take(&models.User{}).Delete(&models.User{}).Error
	if err != nil {
		responses.ERROR(w, http.StatusBadRequest, err)
		return
	}

	responses.JSON(w, http.StatusAccepted, "deleted")

}

// ConfirmOldPassword is a func
func ConfirmOldPassword(password string, email string) (uint32, bool) {
	dummyuser := models.User{}
	dummyuser.Email = email
	hashPwd, err := security.Hash(password)
	if err != nil {
		fmt.Println(err)
		return 0, false
	}
	fmt.Println(password)
	hashPwd1 := string(hashPwd)
	db, _ := database.Connect()
	defer db.Close()
	err = db.Debug().Model(models.User{}).Where("email = ?", dummyuser.Email).Take(&dummyuser).Error
	if err != nil {
		return 0, false
	}
	fmt.Println(hashPwd1)
	fmt.Println(dummyuser.Password)
	fmt.Println(dummyuser.Email)
	fmt.Println(dummyuser.ID)
	fmt.Println(dummyuser.UserName)

	// if dummyuser.Password != hashPwd1 {
	// 	return false
	// }
	// return true
	err = security.VerifyPassword(dummyuser.Password, password)
	if err != nil {
		return dummyuser.ID, false
	}
	return dummyuser.ID, true
}
