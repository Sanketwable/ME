package crud

import (
	"api/models"
	"api/utils/channels"

	"github.com/jinzhu/gorm"
)

type repositoryPostCRUD struct {
	db *gorm.DB
}

//NewRepositoryPostCRUD is func to return repo
func NewRepositoryPostCRUD(db *gorm.DB) *repositoryPostCRUD {
	return &repositoryPostCRUD{db}
}

// SavePost is used to save posts
func (r *repositoryPostCRUD) SavePost(post models.Post) (models.Post, error) {
	var err error
	done := make(chan bool)
	go func(ch chan<- bool) {
		err = r.db.Debug().Model(models.Post{}).Create(&post).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return post, nil
	}
	return models.Post{}, err
}

// SaveComment is used to save comments
func (r *repositoryPostCRUD) SaveComment(comment models.Comment) (models.Comment, error) {
	var err error
	done := make(chan bool)
	go func(ch chan<- bool) {
		err = r.db.Debug().Model(models.Post{}).Create(&comment).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return comment, nil
	}
	return models.Comment{}, err

}

// FindPosts is used to find posts corresponding to classid
func (r *repositoryPostCRUD) FindPosts(class_id uint32) ([]models.Post, error) {
	var err error
	Posts := []models.Post{}
	done := make(chan bool)
	go func(ch chan<- bool) {
		defer close(ch)
		err = r.db.Debug().Model(models.Post{}).Where("class_id = ?", class_id).Limit(100).Find(&Posts).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return Posts, nil
	}
	return nil, err
}

// FindComments is used to find comments corresponding to post
func (r *repositoryPostCRUD) FindComments(post_id uint32) ([]models.Comment, error) {
	var err error
	Comments := []models.Comment{}
	done := make(chan bool)
	go func(ch chan<- bool) {
		defer close(ch)
		err = r.db.Debug().Model(models.Post{}).Where("post_id = ?", post_id).Limit(100).Find(&Comments).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return Comments, nil
	}
	return nil, err
}
