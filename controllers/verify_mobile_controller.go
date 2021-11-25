package controllers

import (
	"api/auth"
	"api/database"
	"api/models"
	"api/repository"
	"api/repository/crud"
	"api/responses"
	"net/http"
)

// VerifyMobile is endpoint to verify the link on sms send on mobile
func VerifyMobile(w http.ResponseWriter, r *http.Request) {
	
	id, _ := auth.ExtractTokenID(r)

	user := models.User{}
	user.ID = id

	user = findUser(user)
	message := []byte("verified")
	

	// db, err := database.Connect()
	// if err != nil {
	// 	responses.ERROR(w, http.StatusInternalServerError, err)
	// 	return
	// }
	// defer db.Close()

	if user.ID != 0 && user.LoginType == "faculty" {
		repo := crud.NewRepositoryFacultyInfoCRUD(database.DB)

		func(FacultyInfoRepository repository.FacultyInfoRepository) {
			err := FacultyInfoRepository.FacultyMobileVerify(uint64(id))
			if err != nil {
				responses.ERROR(w, http.StatusBadRequest, err)
				return
			}
			w.WriteHeader(http.StatusOK)
			w.Write(message)
		}(repo)
	} else if user.ID != 0 && user.LoginType == "student" {
		repo := crud.NewRepositoryStudentInfoCRUD(database.DB)

		func(StudentInfoRepository repository.StudentInfoRepository) {
			err := StudentInfoRepository.StudentMobileVerify(uint64(id))
			if err != nil {
				responses.ERROR(w, http.StatusBadRequest, err)
				return
			}
			w.WriteHeader(http.StatusOK)
			w.Write(message)
		}(repo)

	}

}
