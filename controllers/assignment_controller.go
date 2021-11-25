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
)

// CreateAssignment is Handler Func to create new assignment
func CreateAssignment(w http.ResponseWriter, r *http.Request) {
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
	assignment := models.Assignment{}
	err = json.Unmarshal(body, &assignment)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}

	fileassignment := assignment.FileAssignment
	formassignment := assignment.FormAssignment
	questions := assignment.FormAssignment.Questions

	// db, err := database.Connect()
	// if err != nil {
	// 	responses.ERROR(w, http.StatusInternalServerError, err)
	// 	return
	// }
	// defer db.Close()

	repo := crud.NewRepositoryAssignmentCRUD(database.DB)

	func(assignmentRepository repository.AssignmentRepository) {
		if assignment.Type == 0 {
			assignment, err = assignmentRepository.SaveFileAssigment(assignment, fileassignment)
			if err != nil {
				responses.ERROR(w, http.StatusUnprocessableEntity, err)
			} else {
				responses.JSON(w, http.StatusOK, assignment)
			}
			return
		} else {
			assignment, err = assignmentRepository.SaveFormAssigment(assignment, formassignment, questions)
			if err != nil {
				responses.ERROR(w, http.StatusUnprocessableEntity, err)
			} else {
				responses.JSON(w, http.StatusOK, assignment)
			}
			return
		}
	}(repo)

}

// GetAssignment is handler func to get list of assignments corresponding to class
func GetAssignment(w http.ResponseWriter, r *http.Request) {
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

	repo := crud.NewRepositoryAssignmentCRUD(database.DB)

	func(assignmentRepository repository.AssignmentRepository) {
		assignment, err := assignmentRepository.FindAssignment(uint32(classID))
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, assignment)
	}(repo)
}

// GetFormAssignment is Handler func to get information about Form assignment
func GetFormAssignment(w http.ResponseWriter, r *http.Request) {
	_, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}
	cID := r.URL.Query().Get("assignment_id")
	assignmentID, err := strconv.Atoi(cID)
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

	repo := crud.NewRepositoryAssignmentCRUD(database.DB)

	func(assignmentRepository repository.AssignmentRepository) {
		formassignment, err := assignmentRepository.FindFormAssignment(uint32(assignmentID))
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, formassignment)
	}(repo)
}

// GetFileAssignment is Handler func to get information about File assignment
func GetFileAssignment(w http.ResponseWriter, r *http.Request) {
	_, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}
	cID := r.URL.Query().Get("assignment_id")
	assignmentID, err := strconv.Atoi(cID)
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

	repo := crud.NewRepositoryAssignmentCRUD(database.DB)

	func(assignmentRepository repository.AssignmentRepository) {
		fileassignment, err := assignmentRepository.FindFileAssignment(uint32(assignmentID))
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, fileassignment)
	}(repo)
}
