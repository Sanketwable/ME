package models

// Post is a struct of post in class
type Post struct {
	PostID      uint32    `gorm:"primary_key;auto_increment" json:"post_id"`
	ClassID     uint32    `gorm:"not null;" json:"class_id"`
	UserID      uint32    `gorm:"not null" json:"user_id"`
	FirstName   string    `json:"first_name"`
	LastName    string    `json:"last_name"`
	Description string    `gorm:"" json:"description"`
	Time        string    `gorm:"" json:"time"`
	Comments    []Comment `json:"comment"`
}

// Comment is used to store comment on any post
type Comment struct {
	CommentID uint32 `gorm:"primary_key;auto_increment" json:"comment_id"`
	PostID    uint32 `gorm:"not null" json:"post_id"`
	UserID    uint32 `gorm:"not null" json:"user_id"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Comment   string `gorm:"" json:"comment"`
	Time      string `gorm:"" json:"time"`
}
