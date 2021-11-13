package repository

import (
	"api/models"
)

type TempOTPRepository interface {
	Save(models.TempOTP) (models.TempOTP, error)
	FindByEmail(string, models.TempOTP) (models.TempOTP, error)
	UpdateTempOTP(string, models.TempOTP) (int64, error)
	Delete(string, models.TempOTP) (int64, error)
}
