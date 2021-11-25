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

// CreateClass is a handler func used to create new class
func CreateClass(w http.ResponseWriter, r *http.Request) {
	faculty_id, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}
	dummyfaculty := models.User{}
	dummyfaculty.ID = faculty_id
	dummyfaculty = findUser(dummyfaculty)
	if dummyfaculty.LoginType != "faculty" {
		err := errors.New("only faculty can create class")
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	class := models.Class{}
	err = json.Unmarshal(body, &class)
	class.FacultyID = faculty_id
	class.ClassCode = class.Branch[:2] + strconv.Itoa(int(class.ClassID)) + class.Subject[:2] + strconv.Itoa(int(class.Year)) + "AZ" + strconv.Itoa(int(class.FacultyID))

	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	// db, err := database.Connect()
	// if err != nil {
	// 	responses.ERROR(w, http.StatusInternalServerError, err)
	// 	return
	// }
	// defer db.Close()

	repo := crud.NewRepositoryClassCRUD(database.DB)

	func(classRepository repository.ClassRepository) {
		class, err = classRepository.Save(class)
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, class)
	}(repo)

}

// GetClass is a handler func to get details of class
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
	// db, err := database.Connect()
	// if err != nil {
	// 	responses.ERROR(w, http.StatusInternalServerError, err)
	// 	return
	// }
	// defer db.Close()

	repo := crud.NewRepositoryClassCRUD(database.DB)

	func(classRepository repository.ClassRepository) {
		class, err := classRepository.FindById(uint32(classID))
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, class)
	}(repo)
}

// AddClassWithEmail is handler func to add student to class with the help of email
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

	// db, err := database.Connect()
	// if err != nil {
	// 	responses.ERROR(w, http.StatusInternalServerError, err)
	// 	return
	// }
	// defer db.Close()

	repo := crud.NewRepositoryClassCRUD(database.DB)
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

// AddClassWithClassCode is handler func to add class to student class list by using class code
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
	// db, err := database.Connect()
	// if err != nil {
	// 	responses.ERROR(w, http.StatusInternalServerError, err)
	// 	return
	// }
	// defer db.Close()

	classstudent := models.ClassStudent{}
	classstudent.ClassID = uint32(dummyclass.ClassID)
	classstudent.UserID = userID

	repo := crud.NewRepositoryClassCRUD(database.DB)

	func(classRepository repository.ClassRepository) {
		err := classRepository.AddStudent(classstudent)
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, "user added")
	}(repo)

}

// GetClasses is handler func to get list of classes corresponding to userid
func GetClasses(w http.ResponseWriter, r *http.Request) {
	userID, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}
	dummyfaculty := models.User{}
	dummyfaculty.ID = userID

	dummyfaculty = findUser(dummyfaculty)
	classes := []models.Class{}
	// db, err := database.Connect()
	// if err != nil {
	// 	responses.ERROR(w, http.StatusInternalServerError, err)
	// 	return
	// }
	// defer db.Close()

	repo := crud.NewRepositoryClassCRUD(database.DB)

	func(classRepository repository.ClassRepository) {
		if dummyfaculty.LoginType == "faculty" {
			classes, err = classRepository.FindClassesFaculty(uint32(userID))
			if err != nil {
				responses.ERROR(w, http.StatusUnprocessableEntity, err)
				return
			}
		} else if dummyfaculty.LoginType == "student" {
			classes, err = classRepository.FindAll(uint32(userID))
			if err != nil {
				responses.ERROR(w, http.StatusUnprocessableEntity, err)
				return
			}
			
		}
	}(repo)
	last := len(classes) - 1
	for i := 0; i < len(classes)/2; i++ {
        classes[i], classes[last-i] = classes[last-i], classes[i]
    }
	responses.JSON(w, http.StatusOK, classes)

}

// DeleteClass is Faculty handler func to delete class
func DeleteClass(w http.ResponseWriter, r *http.Request) {

}

// UpdateClass is Faculty handler func to delete class
func UpdateClass(w http.ResponseWriter, r *http.Request) {

}

func findClass(dummyclass models.Class) models.Class {
	var err error
	// db, _ := database.Connect()
	// defer db.Close()
	err = database.DB.Debug().Model(models.Class{}).Where("class_code = ?", dummyclass.ClassCode).Take(&dummyclass).Error
	if err != nil {
		dummyclass.ClassID = 0
	}
	return dummyclass
}
func findUser(dummyuser models.User) models.User {
	var err error
	// db, _ := database.Connect()
	// defer db.Close()
	err = database.DB.Debug().Model(models.User{}).Where("id = ?", dummyuser.ID).Take(&dummyuser).Error
	if err != nil {
		dummyuser.ID = 0
		return dummyuser
	}
	return dummyuser
}
