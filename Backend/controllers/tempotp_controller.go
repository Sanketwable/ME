package controllers

import (

	"api/database"
	"api/models"
	"api/repository"
	"api/repository/crud"

	"fmt"

	"github.com/jinzhu/gorm"
)

type repositoryTempOTPCRUD struct {
	db *gorm.DB
}

//SaveTemp is func
func SaveTemp(tempotp models.TempOTP) error {

	db, err := database.Connect()
	if err != nil {
		return err
	}
	defer db.Close()

	repo := crud.NewRepositoryTempOTPCRUD(db)

	func(tempOTPRepository repository.TempOTPRepository) {
		_, err1 := tempOTPRepository.Save(tempotp)
		if err1 != nil {
			err = err1
			return
		}
	}(repo)
	return err

}

// UpdateTemp is a func
func UpdateTemp(tempotp models.TempOTP) {
	email := tempotp.Email

	db, err := database.Connect()
	if err != nil {
		fmt.Println(err)
		return
	}
	defer db.Close()

	repo := crud.NewRepositoryTempOTPCRUD(db)

	func(tempOTPRepository repository.TempOTPRepository) {
		_, err := tempOTPRepository.UpdateTempOTP(email, tempotp)
		if err != nil {
			fmt.Println(err)
			return
		}
	}(repo)
}

// DeleteTemp is a func
func DeleteTemp(email string, tempotp models.TempOTP) {
	db, err := database.Connect()
	if err != nil {
		fmt.Println(err)
		return
	}
	defer db.Close()

	repo := crud.NewRepositoryTempOTPCRUD(db)

	func(tempOTPRepository repository.TempOTPRepository) {
		_, err := tempOTPRepository.Delete(email, tempotp)
		if err != nil {
			fmt.Println("error is :", err)
			return
		}
	}(repo)

}

// GetTempOTP is a func
func GetTempOTP(tempUser models.TempOTP) (models.TempOTP, error) {
	var err error
	returntemp := models.TempOTP{}
	db, err := database.Connect()
	if err != nil {
		fmt.Println("error is ", err)
		return tempUser, err
	}
	defer db.Close()

	repo := crud.NewRepositoryTempOTPCRUD(db)

	func(tempOTPRepository repository.TempOTPRepository) {
		tempotp, errw := tempOTPRepository.FindByEmail(tempUser.Email, tempUser)
			fmt.Println("Error is ", err)
		returntemp = tempotp
		err = errw
		fmt.Println("in the GetTempOTP returntemp = ", returntemp)
	}(repo)
	if err != nil {
		return returntemp, err
	}
	return returntemp, nil
}
