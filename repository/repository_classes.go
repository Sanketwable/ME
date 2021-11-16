package repository

import "api/models"

type ClassRepository interface {
	Save(models.Class) (models.Class, error)
	FindAll(uint32) ([]models.Class, error)
	FindById(uint32) (models.Class, error)
	Update(uint32, models.Class) (int64, error)
	Delete(uint32) (int64, error)
	AddStudent(models.ClassStudent) (error)
}
