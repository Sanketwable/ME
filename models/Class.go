package models

// Class details for particular faculty
type Class struct {
	ClassID   uint32 `gorm:"primary_key;auto_increment" json:"class_id"`
	ClassCode string `gorm:"not null;unique" json:"class_code"`
	FacultyID uint32 `gorm:"" json:"faculty_id"`
	ClassLink string `gorm:"" json:"link"`
	Year      uint32 `gorm:"" json:"year"`
	Branch    string `gorm:"" json:"branch"`
	Subject   string `gorm:"" json:"subject"`
	ImageLink string `gorm:"" json:"image_link"`
}

type ClassStudent struct {
	ClassID uint32 `gorm:"" json:"class_id"`
	UserID  uint32 `gorm:"" json:"user_id"`
}
