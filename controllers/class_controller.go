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
	"io/ioutil"
	"net/http"
	"strconv"
)

func CreateClass(w http.ResponseWriter, r *http.Request) {
	_, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	class := models.Class{}
	class.ClassCode = class.Branch[:2] + strconv.Itoa(int(class.ClassID)) + class.Subject[:2] + strconv.Itoa(int(class.FacultyID)) + "AZ" + strconv.Itoa(int(class.Year))
	err = json.Unmarshal(body, &class)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	db, err := database.Connect()
	if err != nil {
		responses.ERROR(w, http.StatusInternalServerError, err)
		return
	}
	defer db.Close()

	repo := crud.NewRepositoryClassCRUD(db)

	func(classRepository repository.ClassRepository) {
		class, err = classRepository.Save(class)
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, class)
	}(repo)

}

func GetClass(w http.ResponseWriter, r *http.Request) {
	// get class with class id
	_, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}
	cID := r.URL.Query().Get("class_id")
	classID, err := strconv.Atoi(cID)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	db, err := database.Connect()
	if err != nil {
		responses.ERROR(w, http.StatusInternalServerError, err)
		return
	}
	defer db.Close()

	repo := crud.NewRepositoryClassCRUD(db)

	func(classRepository repository.ClassRepository) {
		class, err := classRepository.FindById(uint32(classID))
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, class)
	}(repo)
}

func AddClassWithEmail(w http.ResponseWriter, r *http.Request) {
	_, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}
	email := r.URL.Query().Get("email")
	cID := r.URL.Query().Get("class_id")
	classID, err := strconv.Atoi(cID)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}
	dummyuser := models.User{}
	dummyuser.Email = email
	dummyuser = findEmail(dummyuser)
	if dummyuser.ID == 0 {
		err := errors.New("no such student exist")
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}

	db, err := database.Connect()
	if err != nil {
		responses.ERROR(w, http.StatusInternalServerError, err)
		return
	}
	defer db.Close()

	repo := crud.NewRepositoryClassCRUD(db)
	classstudent := models.ClassStudent{}
	classstudent.ClassID = uint32(classID)
	classstudent.UserID = dummyuser.ID

	func(classRepository repository.ClassRepository) {
		err := classRepository.AddStudent(classstudent)
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, "user added")
	}(repo)
}

func AddClassWithClassCode(w http.ResponseWriter, r *http.Request) {
	userID, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}
	code := r.URL.Query().Get("code")
	dummyclass := models.Class{}
	dummyclass.ClassCode = code
	dummyclass = findClass(dummyclass)
	if dummyclass.ClassID == 0 {
		err := errors.New("no such class exist")
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}
	db, err := database.Connect()
	if err != nil {
		responses.ERROR(w, http.StatusInternalServerError, err)
		return
	}
	defer db.Close()

	classstudent := models.ClassStudent{}
	classstudent.ClassID = uint32(dummyclass.ClassID)
	classstudent.UserID = userID
	
	repo := crud.NewRepositoryClassCRUD(db)
	
	func(classRepository repository.ClassRepository) {
		err := classRepository.AddStudent(classstudent)
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, "user added")
	}(repo)

	
}
func GetClasses(w http.ResponseWriter, r *http.Request) {
	userID, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}
	// get all the classes for user id
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	db, err := database.Connect()
	if err != nil {
		responses.ERROR(w, http.StatusInternalServerError, err)
		return
	}
	defer db.Close()

	repo := crud.NewRepositoryClassCRUD(db)

	func(classRepository repository.ClassRepository) {
		classes, err := classRepository.FindAll(uint32(userID))
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, classes)
	}(repo)

}

func DeleteClass(w http.ResponseWriter, r *http.Request) {

}

func UpdateClass(w http.ResponseWriter, r *http.Request) {

}
func findClass(dummyclass models.Class) models.Class {
	var err error
	db, _ := database.Connect()
	defer db.Close()
	err = db.Debug().Model(models.Class{}).Where("class_code = ?", dummyclass.ClassCode).Take(&dummyclass).Error
	if err != nil {
		dummyclass.ClassID = 0
	}
	return dummyclass
}
