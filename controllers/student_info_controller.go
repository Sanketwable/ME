package controllers

import (
	"api/auth"
	"api/config"
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
)

//CreateStudentStudentInfo is Handler Function to create save Student information about student
func CreateStudentInfo(w http.ResponseWriter, r *http.Request) {
	pid, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	studentInfo := models.StudentInfo{}
	err = json.Unmarshal(body, &studentInfo)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}

	studentInfo.UserID = pid

	mobileNo := studentInfo.PhoneNo
	fmt.Println(mobileNo)

	dummyStudentinfo := models.StudentInfo{}
	dummyStudentinfo.PhoneNo = studentInfo.PhoneNo
	dummyStudentinfo = findPhoneNo(dummyStudentinfo)

	if dummyStudentinfo.PhoneNo != "0" && dummyStudentinfo.OTPVerified && dummyStudentinfo.UserID == pid {
		err := errors.New("user data already exits")
		responses.ERROR(w, http.StatusAlreadyReported, err)
		return
	}

	token := auth.ExtractToken(r)
	herokuURL := config.HEROKUURL
	smsContent := `Click on the URL to verify your mobile number for Study App URL : ` + herokuURL +`/verifymobile?token=` + token
	smsErr := SendCellularSMS(mobileNo, smsContent)
	if smsErr == nil {
		// db, err := database.Connect()
		// if err != nil {
		// 	responses.ERROR(w, http.StatusInternalServerError, err)
		// 	return
		// }
		// defer db.Close()

		repo := crud.NewRepositoryStudentInfoCRUD(database.DB)

		func(StudentInfoRepository repository.StudentInfoRepository) {
			studentInfo, err = StudentInfoRepository.Save(studentInfo)
			if err != nil {
				responses.ERROR(w, http.StatusUnprocessableEntity, err)
				return
			}
			w.Header().Set("Location", fmt.Sprintf("%s%s", r.Host, r.URL.Path))
			responses.JSON(w, http.StatusCreated, studentInfo)
		}(repo)
	} else {
		responses.JSON(w, http.StatusCreated, "error verifying phone")
	}

}

//GetStudentInfo is a func
func GetStudentInfo(w http.ResponseWriter, r *http.Request) {

	pid, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}

	// db, err := database.Connect()
	// if err != nil {
	// 	responses.ERROR(w, http.StatusInternalServerError, err)
	// 	return
	// }
	// defer db.Close()
	repo := crud.NewRepositoryStudentInfoCRUD(database.DB)

	func(StudentInfoRepository repository.StudentInfoRepository) {
		StudentInfo, err := StudentInfoRepository.FindById(uint64(pid))
		if err != nil {
			responses.ERROR(w, http.StatusBadRequest, err)
			return
		}
		responses.JSON(w, http.StatusOK, StudentInfo)
	}(repo)

}

//UpdateStudentInfo is a func
func UpdateStudentInfo(w http.ResponseWriter, r *http.Request) {

	pid, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	StudentInfo := models.StudentInfo{}
	err = json.Unmarshal(body, &StudentInfo)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}

	StudentInfo.UserID = pid

	// db, err := database.Connect()
	// if err != nil {
	// 	responses.ERROR(w, http.StatusInternalServerError, err)
	// 	return
	// }
	// defer db.Close()

	repo := crud.NewRepositoryStudentInfoCRUD(database.DB)

	func(StudentInfoRepository repository.StudentInfoRepository) {
		_, err = StudentInfoRepository.Update(uint64(pid), StudentInfo)
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		w.Header().Set("Location", fmt.Sprintf("%s%s", r.Host, r.URL.Path))
	}(repo)

	responses.JSON(w, http.StatusCreated, "Updated")

}

func findPhoneNo(dummyuser models.StudentInfo) models.StudentInfo {
	// var err error
	// db, _ := database.Connect()
	// defer db.Close()
	err := database.DB.Debug().Model(models.StudentInfo{}).Where("phone_no = ? and otp_verified = ?", dummyuser.PhoneNo, true).Take(&dummyuser).Error
	if err != nil {
		dummyuser.PhoneNo = "0"
		return dummyuser
	}
	return dummyuser
}
