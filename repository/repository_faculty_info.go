package repository

import "api/models"

type FacultyInfoRepository interface {
	Save(models.FacultyInfo, models.Qualification) (models.FacultyInfo, error)
	FindById(uint64) (models.FacultyInfo, error)
	Update(uint64, models.FacultyInfo, models.Qualification) (int64, error)
}