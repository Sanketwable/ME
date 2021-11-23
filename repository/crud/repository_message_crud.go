package crud

import (
	"api/models"
	"api/utils/channels"

	"github.com/jinzhu/gorm"
)

type repositoryMessageCRUD struct {
	db *gorm.DB
}

//NewRepositoryMessageCRUD is func that returns repo
func NewRepositoryMessageCRUD(db *gorm.DB) *repositoryMessageCRUD {
	return &repositoryMessageCRUD{db}
}

// Save is used to save the basic student info
func (r *repositoryMessageCRUD) Save(message models.Message) (models.Message, error) {
	var err error
	done := make(chan bool)
	go func(ch chan<- bool) {
		err = r.db.Debug().Model(models.Message{}).Create(&message).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return message, nil
	}
	return models.Message{}, err
}

// FindAll is used to find all students
func (r *repositoryMessageCRUD) FindAll() ([]models.Message, error) {
	var err error
	posts := []models.Message{}
	done := make(chan bool)
	go func(ch chan<- bool) {
		err = r.db.Debug().Model(models.Message{}).Limit(100).Find(&posts).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return posts, nil
	}
	return nil, err
}

// FindById is a func
func (r *repositoryMessageCRUD) FindByClassID(classID uint64) ([]models.Message, error) {
	var err error
	messages := []models.Message{}
	done := make(chan bool)
	go func(ch chan<- bool) {
		err = r.db.Debug().Model(models.Message{}).Limit(500).Find(&messages).Where("class_id = ?", classID).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return messages, nil
	}
	return []models.Message{}, err
}
