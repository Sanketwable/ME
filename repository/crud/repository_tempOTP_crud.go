package crud

import (
	"api/models"
	"api/utils/channels"
	"errors"
	"fmt"

	"github.com/jinzhu/gorm"
)

type repositoryTempOTPCRUD struct {
	db *gorm.DB
}
//NewRepositoryTempOTPCRUD is func
func NewRepositoryTempOTPCRUD(db *gorm.DB) *repositoryTempOTPCRUD{
	return &repositoryTempOTPCRUD{db}
}

func (r *repositoryTempOTPCRUD) Save(tempotp models.TempOTP) (models.TempOTP, error) {
	var err1 error = nil
	done := make(chan bool)
	go func(ch chan<- bool) {
		err := r.db.Debug().Model(models.TempOTP{}).Create(&tempotp).Error
		if err != nil {
			err1 = err
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return tempotp, err1
	}
	return models.TempOTP{}, err1
}

func (r *repositoryTempOTPCRUD) FindByEmail(email string, tempotp models.TempOTP) (models.TempOTP, error) {
	var err error

	done := make(chan bool)
	go func(ch chan<- bool) {
		defer close(ch)

		err = r.db.Debug().Model(models.TempOTP{}).Where("email = ?", email).Take(&tempotp).Error
		if err != nil {
			fmt.Println("error in FindByEmail is : ", err )
			ch <- false
			return
		}
		fmt.Println("in the findByEmail tempotp = ", tempotp)
		ch <- true
	}(done)

	if channels.OK(done) {
		return tempotp, nil
	}
	if gorm.IsRecordNotFoundError(err) {
		return tempotp, errors.New("user not found")
	}
	return tempotp, err
}

func (r *repositoryTempOTPCRUD) Delete(email string, tempotp models.TempOTP) (int64, error) {
	var rs *gorm.DB 
	done := make(chan bool) 
	go func(ch chan<- bool) {
		defer close(ch)
		rs = r.db.Debug().Model(models.TempOTP{}).Where("email = ?", email).Take(&models.TempOTP{}).Delete(&models.TempOTP{})
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
func (r *repositoryTempOTPCRUD) UpdateTempOTP(email string, tempotp  models.TempOTP) (int64, error) {
	var rs *gorm.DB
	done := make(chan bool) 
	go func(ch chan<- bool) {
		rs = r.db.Debug().Model(models.TempOTP{}).Where("email = ?", email).Find(&models.TempOTP{}).Take(&models.TempOTP{}).UpdateColumns(
			map[string]interface{}{
				"otp": tempotp.OTP,
			},
		)
		ch <- true
	}(done)

	if channels.OK(done) {
		if rs.Error != nil {
			if gorm.IsRecordNotFoundError(rs.Error) {
				return 0, errors.New("Post not found")
			}
			return 0, rs.Error
		}
		return rs.RowsAffected, nil
	}
	return 0, rs.Error
}



