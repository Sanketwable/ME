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

// SaveFileAssigment is a assignment func to save the assignment details
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
		fileassignment.CreatedAt = time.Now().String()
		err = r.db.Debug().Model(models.FileAssignment{}).Create(&fileassignment).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return assignment, nil
	}
	return models.Assignment{}, err
}

// SaveFormAssigment is function to store form assignment
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

// FindAssignment is function to query DB to find assignment corresponding to class
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

// FindFormAssignment is used to find form assignment
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

// FindFileAssignment is used to find file assignment
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

func (r *repositoryAssignmentCRUD) SaveAssignmentStatus(sa models.StudentAssignment) (models.StudentAssignment, error) {
	var err error
	done := make(chan bool)
	go func(ch chan<- bool) {
		err = r.db.Debug().Model(models.Assignment{}).Create(&sa).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return sa, nil
	}
	return models.StudentAssignment{}, err
}

func (r *repositoryAssignmentCRUD) GetAssignmentStatus(assignmentID uint32, studentID uint32) (models.StudentAssignment, error) {
	sa := models.StudentAssignment{}
	var err error

	done := make(chan bool)
	go func(ch chan<- bool) {
		err = r.db.Debug().Model(models.StudentAssignment{}).Where("assignment_id = ? AND student_id = ?", assignmentID, studentID).Find(&sa).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return sa, nil
	}
	return models.StudentAssignment{}, err
}
