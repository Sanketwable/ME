package crud

import (
	"api/models"
	"api/utils/channels"
	"errors"
	"strconv"

	"github.com/jinzhu/gorm"
)

type repositoryClassCRUD struct {
	db *gorm.DB
}
//NewRepositoryClassCRUD is func
func NewRepositoryClassCRUD(db *gorm.DB) *repositoryClassCRUD{
	return &repositoryClassCRUD{db}
}

func (r *repositoryClassCRUD) Save(class models.Class) (models.Class, error) {
	var err error
	done := make(chan bool) 
	go func(ch chan<- bool) {
		err = r.db.Debug().Model(models.Class{}).Create(&class).Error
		if err != nil {
			ch <- false
			return
		}
		class.ClassCode =  class.ClassCode + strconv.Itoa(int(class.ClassID)) + "k"
		err = r.db.Debug().Model(models.Class{}).Where("class_id = ?", class.ClassID).Take(&models.Class{}).Updates(class).Error
		ch <- true
	}(done)

	if channels.OK(done) {
		return class, nil
	}
	return models.Class{}, err
}

func (r *repositoryClassCRUD) FindAll(user_id uint32) ([]models.Class, error) {
	var err error
	Class := []models.Class{}
	ClassStudent := []models.ClassStudent{}
	done := make(chan bool) 
	go func(ch chan<- bool) {
		defer close(ch)
		err = r.db.Debug().Model(models.ClassStudent{}).Where("user_id = ?", user_id).Limit(100).Find(&ClassStudent).Error
		for _, value := range ClassStudent {
			class := models.Class{}
			class_id := value.ClassID
			err = r.db.Debug().Model(models.Class{}).Where("class_id = ?", class_id).Take(&class).Error
			Class = append(Class, class)
		}
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return Class, nil
	}
	return nil, err
}
func (r *repositoryClassCRUD) FindClassesFaculty(faculty_id uint32) ([]models.Class, error) {
	var err error
	class := []models.Class{}
	done := make(chan bool) 
	go func(ch chan<- bool) {
		defer close(ch)
		err = r.db.Debug().Model(models.Class{}).Where("faculty_id = ?", faculty_id).Limit(100).Find(&class).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return class, nil
	}
	return nil, err
}

func (r *repositoryClassCRUD) FindById(class_id uint32) (models.Class, error) {
	var err error
	class := models.Class{}

	done := make(chan bool) 
	go func(ch chan<- bool) {
		defer close(ch)

		err = r.db.Debug().Model(models.Class{}).Where("class_id = ?", class_id).Take(&class).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return class, nil
	}
	if gorm.IsRecordNotFoundError(err) {
		return models.Class{ }, errors.New("class not found")
	}
	return models.Class{ }, err
}

func (r *repositoryClassCRUD) Update(class_id uint32, class models.Class) (int64, error) {
	var rs *gorm.DB
	
	done := make(chan bool) 
	go func(ch chan<- bool) {
		defer close(ch)
		rs = r.db.Debug().Model(models.Class{}).Where("class_id = ?", class_id).Take(&models.Class{}).Updates(class)
		ch <- true
	}(done)

	if channels.OK(done) {
		if rs.Error != nil {
			return 0, rs.Error
		}
		return rs.RowsAffected, nil
	}
	return 0, rs.Error
}

func (r *repositoryClassCRUD) Delete(class_id uint32) (int64, error) {
	var rs *gorm.DB 
	done := make(chan bool) 
	go func(ch chan<- bool) {
		defer close(ch)
		rs = r.db.Debug().Model(models.ClassStudent{}).Where("class_id = ?", class_id).Take(&models.ClassStudent{}).Delete(&models.ClassStudent{})
		rs = r.db.Debug().Model(models.Class{}).Where("class_id = ?", class_id).Take(&models.Class{}).Delete(&models.Class{})
		ch <- true
	}(done)

	if channels.OK(done) {
		if rs.Error != nil {
			return 0, rs.Error
		}
		return rs.RowsAffected, nil
	}
	return 0, rs.Error
}

func (r *repositoryClassCRUD) AddStudent(classstudent models.ClassStudent) (error) {
	var err error
	done := make(chan bool) 
	go func(ch chan<- bool) {
		err = r.db.Debug().Model(models.ClassStudent{}).Create(&classstudent).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return  nil
	}
	return err
}

