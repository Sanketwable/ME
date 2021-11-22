package auto

import (
	"api/database"
	"api/models"
	//"api/utils/console"
	"log"
)

//Load is function to create basic schema of DB
func Load() {
	db, err := database.Connect()
	if err != nil {
		log.Fatal("this is an error :", err)
	}
	defer db.Close()

	// err = db.Debug().DropTableIfExists(&models.User{}, &models.StudentInfo{},&models.FacultyInfo{}, models.TempOTP{}, models.Qualification{}, models.Class{}, models.ClassStudent{}).Error
	// if err != nil {
	// 	log.Fatal("this is an error :", err)
	// }

	err = db.Debug().AutoMigrate(&models.User{}, &models.StudentInfo{},&models.FacultyInfo{}, models.TempOTP{}, models.Qualification{}, models.Class{}, models.ClassStudent{}, models.Assignment{}, models.FileAssignment{}, models.FormAssignment{}, models.Question{}, models.StudentAssignment{}, models.Post{}, models.Comment{}).Error
	if err != nil {
		log.Fatal("error occured : ", err)
	}

	// err = db.Debug().Model(&models.BasicInfo{}).AddForeignKey("author_id","users(id)","cascade","cascade").Error
	// if err != nil {
	// 	log.Fatal("error occured : ", err )
	// }

}
