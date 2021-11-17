package crud

import (
	"api/models"
	"api/utils/channels"
	"errors"

	"github.com/jinzhu/gorm"
)

type repositoryFacultyInfoCRUD struct {
	db *gorm.DB
}

//NewRepositoryFacultyInfoCRUD is
func NewRepositoryFacultyInfoCRUD(db *gorm.DB) *repositoryFacultyInfoCRUD {
	return &repositoryFacultyInfoCRUD{db}
}

func (r *repositoryFacultyInfoCRUD) Save(Facultyinfo models.FacultyInfo, qualification models.Qualification) (models.FacultyInfo, error) {
	var err error
	done := make(chan bool)
	go func(ch chan<- bool) {
		err = r.db.Debug().Model(models.FacultyInfo{}).Create(&Facultyinfo).Error

		err = r.db.Debug().Model(models.Qualification{}).Create(&qualification).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return Facultyinfo, nil
	}
	return models.FacultyInfo{}, err
}

func (r *repositoryFacultyInfoCRUD) FindAll() ([]models.FacultyInfo, error) {
	var err error
	posts := []models.FacultyInfo{}
	done := make(chan bool)
	go func(ch chan<- bool) {
		err = r.db.Debug().Model(models.FacultyInfo{}).Limit(100).Find(&posts).Error
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
func (r *repositoryFacultyInfoCRUD) FindById(pid uint64) (models.FacultyInfo, error) {
	var err error
	FacultyInfo := models.FacultyInfo{}

	qualification := models.Qualification{}

	done := make(chan bool)
	go func(ch chan<- bool) {
		err = r.db.Debug().Model(models.FacultyInfo{}).Where("user_id = ?", pid).Take(&FacultyInfo).Error

		err = r.db.Debug().Model(models.Qualification{}).Where("user_id = ?", pid).Take(&qualification).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {

		FacultyInfo.Qualification = qualification
		return FacultyInfo, nil
	}
	return models.FacultyInfo{}, err
}

func (r *repositoryFacultyInfoCRUD) Update(pid uint64, FacultyInfo models.FacultyInfo, qualification models.Qualification) (int64, error) {
	var rs *gorm.DB
	done := make(chan bool)
	go func(ch chan<- bool) {
		rs = r.db.Debug().Model(models.FacultyInfo{}).Where("user_id = ?", pid).Take(&models.FacultyInfo{}).Updates(FacultyInfo)
		rs = r.db.Debug().Model(models.Qualification{}).Where("user_id = ?", pid).Take(&models.Qualification{}).Updates(qualification)
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
// FacultyMobileVerify(uint64) (error)
func (r *repositoryFacultyInfoCRUD) FacultyMobileVerify(pid uint64) error {
	var rs *gorm.DB

	done := make(chan bool)
	go func(ch chan<- bool) {
		defer close(ch)
		rs = r.db.Debug().Model(models.FacultyInfo{}).Where("user_id = ?", pid).Find(&models.FacultyInfo{}).Take(&models.FacultyInfo{}).UpdateColumns(
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
