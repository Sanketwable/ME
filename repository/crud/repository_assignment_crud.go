package crud

import (
	"api/models"
	"api/utils/channels"
	"time"

	"github.com/jinzhu/gorm"
)

type repositoryAssignmentCRUD struct {
	db *gorm.DB
}

//NewRepositoryClassCRUD is func
func NewRepositoryAssignmentCRUD(db *gorm.DB) *repositoryAssignmentCRUD {
	return &repositoryAssignmentCRUD{db}
}

func (r *repositoryAssignmentCRUD) SaveFileAssigment(assignment models.Assignment, fileassignment models.FileAssignment) (models.Assignment, error) {
	var err error
	done := make(chan bool)
	go func(ch chan<- bool) {
		err = r.db.Debug().Model(models.Assignment{}).Create(&assignment).Error
		if err != nil {
			ch <- false
			return
		}
		fileassignment.AssignmentID = assignment.AssignmentID
		fileassignment.CreatedAt = time.Now()
		err = r.db.Debug().Model(models.FileAssignment{}).Create(&fileassignment).Error
		if err != nil {
			ch <- false
			return
		}
		assignment.FileAssignment = fileassignment
		ch <- true
	}(done)

	if channels.OK(done) {
		return assignment, nil
	}
	return models.Assignment{}, err
}
func (r *repositoryAssignmentCRUD) SaveFormAssigment(assignment models.Assignment, formassignment models.FormAssignment, questions []models.Question) (models.Assignment, error) {
	var err error
	done := make(chan bool)
	go func(ch chan<- bool) {
		err = r.db.Debug().Model(models.Assignment{}).Create(&assignment).Error
		if err != nil {
			ch <- false
			return
		}
		formassignment.AssignmentID = assignment.AssignmentID
		formassignment.CreatedAt = time.Now()
		err = r.db.Debug().Model(models.FileAssignment{}).Create(&formassignment).Error
		if err != nil {
			ch <- false
			return
		}
		for _, question := range questions {
			question.AssignmentID = assignment.AssignmentID
			err = r.db.Debug().Model(models.Question{}).Create(&question).Error
			if err != nil {
				ch <- false
				return
			}
			formassignment.Questions = append(formassignment.Questions, question)
		}
		assignment.FormAssignment = formassignment
		ch <- true
	}(done)

	if channels.OK(done) {
		return assignment, nil
	}
	return models.Assignment{}, err
}
func (r *repositoryAssignmentCRUD) FindAssignment(classID uint32) ([]models.Assignment, error) {
	var err error

	assignments := []models.Assignment{}

	done := make(chan bool)
	go func(ch chan<- bool) {
		defer close(ch)
		err = r.db.Debug().Model(models.Assignment{}).Where("class_id = ?", classID).Limit(100).Find(&assignments).Error
		if err != nil {
			ch <- false
			return
		}

		ch <- true
	}(done)

	if channels.OK(done) {
		return assignments, nil
	}
	return nil, err
}
func (r *repositoryAssignmentCRUD) FindFormAssignment(assignmentID uint32) (models.FormAssignment, error) {
	var err error

	formassignment := models.FormAssignment{}
	questions := []models.Question{}

	done := make(chan bool)
	go func(ch chan<- bool) {
		defer close(ch)
		err = r.db.Debug().Model(models.Assignment{}).Where("assignment_id = ?", assignmentID).Find(&formassignment).Error
		if err != nil {
			ch <- false
			return
		}
		err = r.db.Debug().Model(models.Question{}).Where("assignment_id = ?", assignmentID).Limit(100).Find(&questions).Error
		formassignment.Questions = questions
		ch <- true
	}(done)

	if channels.OK(done) {
		return formassignment, nil
	}
	return formassignment, err
}
func (r *repositoryAssignmentCRUD) FindFileAssignment(assignmentID uint32) (models.FileAssignment, error) {
	var err error

	fileassignment := models.FileAssignment{}

	done := make(chan bool)
	go func(ch chan<- bool) {
		defer close(ch)
		err = r.db.Debug().Model(models.Assignment{}).Where("assignment_id = ?", assignmentID).Find(&fileassignment).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return fileassignment, nil
	}
	return fileassignment, err
}
