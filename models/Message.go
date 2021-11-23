package models

type Message struct {
	Message_ID uint32 `gorm:"primary_key;auto_increment" json:"message_id"`
	ClassID    uint32 `gorm:"class_id" json:"class_id"`
	UserID     uint32 `gorm:"" json:"user_id"`
	Message    string `gorm:"message" json:"message"`
	FirstName  string `gorm:"first_name" json:"first_name"`
	LastName   string `gorm:"last_name" json:"last_name"`
	Time       string `gorm:"time" json:"time"`
}
