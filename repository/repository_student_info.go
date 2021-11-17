package repository

import "api/models"

type StudentInfoRepository interface {
	Save(models.StudentInfo) (models.StudentInfo, error)
	FindById(uint64) (models.StudentInfo, error)
	Update(uint64, models.StudentInfo) (int64, error)
	StudentMobileVerify(uint64) (error)
}