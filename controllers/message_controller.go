package controllers

import (
	"api/auth"
	"api/database"
	"api/models"
	"api/repository"
	"api/repository/crud"
	"api/responses"
	"encoding/json"
	"io/ioutil"
	"net/http"
	"strconv"
	"time"
)

// GetMessages is function to get messages related to class
func GetMessages(w http.ResponseWriter, r *http.Request) {
	_, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}

	classid := r.URL.Query().Get("class_id")
	class_id, err := strconv.Atoi(classid)
	messages := []models.Message{}

	// db, err := database.Connect()
	// if err != nil {
	// 	responses.ERROR(w, http.StatusInternalServerError, err)
	// 	return
	// }
	// defer db.Close()

	repo := crud.NewRepositoryMessageCRUD(database.DB)

	func(messageRepository repository.MessageRepository) {
		messages, err = messageRepository.FindByClassID(uint64(class_id))
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}

		responses.JSON(w, http.StatusOK, messages)
	}(repo)
}

// AddMessages is function to add new messages related to class
func AddMessages(w http.ResponseWriter, r *http.Request) {
	userID, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}

	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	message := models.Message{}
	err = json.Unmarshal(body, &message)

	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
	}
	message.UserID = userID
	message.Time = time.Now().String()[:20]

	// db, err := database.Connect()
	// if err != nil {
	// 	responses.ERROR(w, http.StatusInternalServerError, err)
	// 	return
	// }
	// defer db.Close()

	repo1 := crud.NewRepositoryStudentInfoCRUD(database.DB)
	studentinfo, err := repo1.FindById(uint64(message.UserID))
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	message.FirstName = studentinfo.FirstName
	message.LastName = studentinfo.LastName

	repo := crud.NewRepositoryMessageCRUD(database.DB)

	func(messageRepository repository.MessageRepository) {
		message, err = messageRepository.Save(message)
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, message)
	}(repo)
}
