package crud

import (
	"api/models"
	"api/utils/channels"
	"errors"

	"github.com/jinzhu/gorm"
)

type repositoryUsersCRUD struct {
	db *gorm.DB
}
//NewRepositoryUsersCRUD is func that return repo
func NewRepositoryUsersCRUD(db *gorm.DB) *repositoryUsersCRUD{
	return &repositoryUsersCRUD{db}
}

// Save is used to save the user's email and password
func (r *repositoryUsersCRUD) Save(user models.User) (models.User, error) {
	var err error
	done := make(chan bool) 
	go func(ch chan<- bool) {
		err = r.db.Debug().Model(models.User{}).Create(&user).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return user, nil
	}
	return models.User{}, err
}

// FindAll is used to find the user's email and password
func (r *repositoryUsersCRUD) FindAll() ([]models.User, error) {
	var err error

	users := []models.User{}

	done := make(chan bool) 
	go func(ch chan<- bool) {
		defer close(ch)
		err = r.db.Debug().Model(models.User{}).Limit(100).Find(&users).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return users, nil
	}
	return nil, err
}

// FindById is used to find the user's email and password by id
func (r *repositoryUsersCRUD) FindById(uid uint32) (models.User, error) {
	var err error

	user := models.User{}

	done := make(chan bool) 
	go func(ch chan<- bool) {
		defer close(ch)

		err = r.db.Debug().Model(models.User{}).Where("id = ?", uid).Take(&user).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return user, nil
	}
	if gorm.IsRecordNotFoundError(err) {
		return models.User{ }, errors.New("user not found")
	}
	return models.User{ }, err
}

// UpdateLastLogin is used to update the last login of the user
func (r *repositoryUsersCRUD) UpdateLastLogin(uid uint32, user models.User) (int64, error) {
	var rs *gorm.DB
 

	done := make(chan bool) 
	go func(ch chan<- bool) {
		defer close(ch)
		rs = r.db.Debug().Model(models.User{}).Where("id = ?", uid).Take(&models.User{}).UpdateColumns(
			map[string]interface{}{	
				"last_login": user.LastLogin,
			},
		)
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

// UpdatePassword is used to update password
func (r *repositoryUsersCRUD) UpdatePassword(uid uint32, user models.User) (int64, error) {
	var rs *gorm.DB
	
	done := make(chan bool) 
	go func(ch chan<- bool) {
		defer close(ch)
		rs = r.db.Debug().Model(models.User{}).Where("id = ?", uid).Take(&models.User{}).UpdateColumns(
			map[string]interface{}{
				"password" :user.Password,
			},
		)
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

// Delete is used to delete the user but not used
func (r *repositoryUsersCRUD) Delete(uid uint32) (int64, error) {
	var rs *gorm.DB 
	done := make(chan bool) 
	go func(ch chan<- bool) {
		defer close(ch)
		rs = r.db.Debug().Model(models.User{}).Where("id = ?", uid).Take(&models.User{}).Delete(&models.User{})
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

