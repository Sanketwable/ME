package models

type Post struct {
	PostID      uint32    `gorm:"primary_key;auto_increment" json:"post_id"`
	ClassID     uint32    `gorm:"not null;" json:"class_id"`
	UserID      uint32    `gorm:"not null" json:"user_id"`
	Description string    `gorm:"" json:"description"`
	Time        string    `gorm:"" json:"time"`
	Comments    []Comment `json:"comment"`
}

type Comment struct {
	PostID  uint32 `gorm:"not null" json:"post_id"`
	UserID  uint32 `gorm:"not null" json:"user_id"`
	Comment string `gorm:"" json:"comment"`
	Time    string `gorm:"" json:"time"`
}
