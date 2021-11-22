package crud

import (
	"api/models"
	"api/utils/channels"
	"errors"
	"fmt"

	"github.com/jinzhu/gorm"
)

type repositoryStudentInfoCRUD struct {
	db *gorm.DB
}

//NewRepositoryStudentInfoCRUD is func that returns repo
func NewRepositoryStudentInfoCRUD(db *gorm.DB) *repositoryStudentInfoCRUD {
	return &repositoryStudentInfoCRUD{db}
}

// Save is used to save the basic student info
func (r *repositoryStudentInfoCRUD) Save(Studentinfo models.StudentInfo) (models.StudentInfo, error) {
	var err error
	done := make(chan bool)
	go func(ch chan<- bool) {
		err = r.db.Debug().Model(models.StudentInfo{}).Create(&Studentinfo).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return Studentinfo, nil
	}
	return models.StudentInfo{}, err
}

// FindAll is used to find all students 
func (r *repositoryStudentInfoCRUD) FindAll() ([]models.StudentInfo, error) {
	var err error
	posts := []models.StudentInfo{}
	done := make(chan bool)
	go func(ch chan<- bool) {
		err = r.db.Debug().Model(models.StudentInfo{}).Limit(100).Find(&posts).Error
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
func (r *repositoryStudentInfoCRUD) FindById(pid uint64) (models.StudentInfo, error) {
	var err error
	StudentInfo := models.StudentInfo{}
	done := make(chan bool)
	go func(ch chan<- bool) {
		err = r.db.Debug().Model(models.StudentInfo{}).Where("user_id = ?", pid).Take(&StudentInfo).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return StudentInfo, nil
	}
	return models.StudentInfo{}, err
}

// Update is used to update student info
func (r *repositoryStudentInfoCRUD) Update(pid uint64, StudentInfo models.StudentInfo) (int64, error) {
	var rs *gorm.DB
	done := make(chan bool)
	go func(ch chan<- bool) {
		rs = r.db.Debug().Model(models.StudentInfo{}).Where("user_id = ?", pid).Take(&models.StudentInfo{}).Updates(StudentInfo)
		ch <- true
	}(done)

	if channels.OK(done) {
		if rs.Error != nil {
			if gorm.IsRecordNotFoundError(rs.Error) {
				return 0, errors.New("post not found")
			}
			return 0, rs.Error
		}
		return rs.RowsAffected, nil
	}
	return 0, rs.Error
}

// StudentMobileVerify is used to update whether mobile has been verified or not
func (r *repositoryStudentInfoCRUD) StudentMobileVerify(pid uint64) error {
	fmt.Println("here in studentMobileVerify")
	var rs *gorm.DB
	done := make(chan bool)
	go func(ch chan<- bool) {
		defer close(ch)
		rs = r.db.Debug().Model(models.StudentInfo{}).Where("user_id = ?", pid).Find(&models.StudentInfo{}).Take(&models.StudentInfo{}).UpdateColumns(
			map[string]interface{}{
				"otp_verified": true,
			},
		)
		ch <- true
	}(done)

	if channels.OK(done) {
		if rs.Error != nil {
			return rs.Error
		}
		return nil
	}
	return rs.Error
}