package repository

import "api/models"

type UserRepository interface {
	Save(models.User) (models.User, error)
	FindAll() ([]models.User, error)
	FindById(uint32) (models.User, error)
	UpdateLastLogin(uint32, models.User) (int64, error)
	UpdatePassword(uint32, models.User) (int64, error)
	Delete(uint32) (int64, error)
}
