package repository

import "api/models"

type PostRepository interface {
	SavePost(models.Post) (models.Post, error)
	SaveComment(models.Comment) (models.Comment, error)
	FindPosts(uint32) ([]models.Post, error)
	FindComments(uint32) ([]models.Comment, error)
}
