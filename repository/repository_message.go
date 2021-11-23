package repository

import "api/models"

type MessageRepository interface {
	Save(models.Message) (models.Message, error)
	FindByClassID(uint64) ([]models.Message, error)
}