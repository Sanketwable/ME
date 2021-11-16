package auto

import (
	"api/database"
	"api/models"
	//"api/utils/console"
	"log"
)

//Load is
func Load() {
	db, err := database.Connect()
	if err != nil {
		log.Fatal("this is an error :", err)
	}
	defer db.Close()

	// err = db.Debug().DropTableIfExists(&models.User{}, &models.StudentInfo{},&models.FacultyInfo{}, models.TempOTP{}, models.AvailableJobs{}, models.Requirement{}, models.Location{}, models.Bookmark{}, models.FileInfo{}, models.InterviewSchedule{}, models.License{}, models.Specialization{}, models.Certification{}, models.Reference{}, models.WorkExperience{}, models.Position{}, models.Education{}, models.Language{}, models.Award{}, models.Project{}, models.Volunteering{}, models.Qualification{}).Error
	// if err != nil {
	// 	log.Fatal("this is an error :", err)
	// }

	err = db.Debug().AutoMigrate(&models.User{}, &models.StudentInfo{},&models.FacultyInfo{}, models.TempOTP{}, models.Qualification{}, models.Class{}, models.ClassStudent{}).Error
	if err != nil {
		log.Fatal("error occured : ", err)
	}

	// err = db.Debug().Model(&models.BasicInfo{}).AddForeignKey("author_id","users(id)","cascade","cascade").Error
	// if err != nil {
	// 	log.Fatal("error occured : ", err )
	// }

}
