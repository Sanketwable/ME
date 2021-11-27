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

//CreateFacultyInfo is a func
func CreateFacultyInfo(w http.ResponseWriter, r *http.Request) {
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
	FacultyInfo := models.FacultyInfo{}
	err = json.Unmarshal(body, &FacultyInfo)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}

	FacultyInfo.UserID = pid

	FacultyInfo.Qualification.UserID = FacultyInfo.UserID
	qualification := FacultyInfo.Qualification
	FacultyInfo.PhoneNo =  "+91" + FacultyInfo.PhoneNo
	mobileNo := FacultyInfo.PhoneNo
	fmt.Println(mobileNo)

	dummyFacultyinfo := models.FacultyInfo{}
	dummyFacultyinfo.PhoneNo = FacultyInfo.PhoneNo
	dummyFacultyinfo = findPhoneNoFaculty(dummyFacultyinfo)

	if dummyFacultyinfo.PhoneNo != "0" && dummyFacultyinfo.OTPVerified && dummyFacultyinfo.UserID == pid {
		err := errors.New("user data already exits")
		responses.ERROR(w, http.StatusAlreadyReported, err)
		return
	}
	token := auth.ExtractToken(r)
	herokuURL := config.HEROKUURL
	smsContent := `Click on the URL to verify your mobile number for Study App URL : ` + herokuURL +`/verifymobile?token=` + token
	smsErr := SendCellularSMS(mobileNo, smsContent)
	// var smsErr error
	if smsErr == nil {
		// db, err := database.Connect()
		// if err != nil {
		// 	responses.ERROR(w, http.StatusInternalServerError, err)
		// 	return
		// }
		// defer db.Close()

		repo := crud.NewRepositoryFacultyInfoCRUD(database.DB)

		func(FacultyInfoRepository repository.FacultyInfoRepository) {
			FacultyInfo, err = FacultyInfoRepository.Save(FacultyInfo, qualification)
			if err != nil {
				responses.ERROR(w, http.StatusUnprocessableEntity, err)
				return
			}
			w.Header().Set("Location", fmt.Sprintf("%s%s", r.Host, r.URL.Path))
			responses.JSON(w, http.StatusCreated, FacultyInfo)
		}(repo)
		return
	} else {
		responses.JSON(w, http.StatusCreated, "error verifying phone")
		return
	}
	

}

//GetFacultyInfo is a func
func GetFacultyInfo(w http.ResponseWriter, r *http.Request) {
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
	repo := crud.NewRepositoryFacultyInfoCRUD(database.DB)

	func(FacultyInfoRepository repository.FacultyInfoRepository) {
		FacultyInfo, err := FacultyInfoRepository.FindById(uint64(pid))
		if err != nil {
			responses.ERROR(w, http.StatusBadRequest, err)
			return
		}
		responses.JSON(w, http.StatusOK, FacultyInfo)
	}(repo)

}

//UpdateFacultyInfo is a func
func UpdateFacultyInfo(w http.ResponseWriter, r *http.Request) {

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
	FacultyInfo := models.FacultyInfo{}
	err = json.Unmarshal(body, &FacultyInfo)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}

	FacultyInfo.UserID = pid

	FacultyInfo.Qualification.UserID = FacultyInfo.UserID
	qualification := FacultyInfo.Qualification

	// db, err := database.Connect()
	// if err != nil {
	// 	responses.ERROR(w, http.StatusInternalServerError, err)
	// 	return
	// }
	// defer db.Close()

	repo := crud.NewRepositoryFacultyInfoCRUD(database.DB)

	func(FacultyInfoRepository repository.FacultyInfoRepository) {
		_, err = FacultyInfoRepository.Update(uint64(pid), FacultyInfo, qualification)
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		w.Header().Set("Location", fmt.Sprintf("%s%s", r.Host, r.URL.Path))
	}(repo)

	responses.JSON(w, http.StatusCreated, "Updated")

}

func findPhoneNoFaculty(dummyuser models.FacultyInfo) models.FacultyInfo {

	var err error
	// db, _ := database.Connect()
	// defer db.Close()
	err = database.DB.Debug().Model(models.FacultyInfo{}).Where("phone_no = ? and otp_verified = ?", dummyuser.PhoneNo, true).Take(&dummyuser).Error
	if err != nil {
		dummyuser.PhoneNo = "0"
		return dummyuser
	}
	return dummyuser
}
