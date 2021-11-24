package controllers

import (
	"api/auth"
	"api/database"
	"api/models"
	"api/repository"
	"api/repository/crud"
	"api/responses"
	"net/http"
	"strconv"
)

type StudentList struct {
	FirstName  string `json:"first_name"`
	LastName   string `json:"last_name"`
	ProfileURL string `json:"profile_url"`
}

func GetStudentList(w http.ResponseWriter, r *http.Request) {
	_, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}
	classid := r.URL.Query().Get("class_id")
	classID, err := strconv.Atoi(classid)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}

	studentList := []StudentList{}

	db, err := database.Connect()
	if err != nil {
		responses.ERROR(w, http.StatusInternalServerError, err)
		return
	}
	defer db.Close()
	classStudents := []models.ClassStudent{}
	_ = db.Debug().Model(models.ClassStudent{}).Where("class_id = ?", classID).Limit(100).Find(&classStudents).Error

	var studentsIDs []uint64
	var mp = make(map[int]int)
	for _, cs := range classStudents {
		mp[int(cs.UserID)]++
		if mp[int(cs.UserID)] == 1 {
			studentsIDs = append(studentsIDs, uint64(cs.UserID))
		}
	}
	
	repo := crud.NewRepositoryStudentInfoCRUD(db)

	func(studentInfoRepository repository.StudentInfoRepository) {
		students, err := studentInfoRepository.FindByClassID(studentsIDs)
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		
		for _, s := range students {
			sl := StudentList{}
			sl.FirstName = s.FirstName
			sl.LastName = s.LastName
			sl.ProfileURL = s.ProfilePhoto
			studentList = append(studentList, sl);
		}

		responses.JSON(w, http.StatusOK, studentList)
	}(repo)
}
