package models

import "time"

// Assignment is models to store assignemnts created by faculty
type Assignment struct {
	AssignmentID   uint32         `gorm:"primary_key;auto_increment" json:"assignment_id"`
	ClassID        uint32         `gorm:"not null" json:"class_id"`
	Name           string         `gorm:"" json:"name"`
	FileAssignment FileAssignment `json:"file_assignment"`
	FormAssignment FormAssignment `json:"form_assignment"`
	Type           uint32         `gorm:"not null" json:"assignment_type"` // 0 for file and 1 for form
	Due            time.Time      `gorm:"" json:"due"`
}

type FileAssignment struct {
	AssignmentID   uint32    `gorm:"not null" json:"assignment_id"`
	Description    string    `gorm:"" json:"description"`
	AttachmentLink string    `gorm:"" json:"attachment_link"`
	Points         uint32    `gorm:"not null" json:"points"`
	CreatedAt      time.Time `gorm:"" json:"created_at"`
}

type FormAssignment struct {
	AssignmentID uint32     `gorm:"not null" json:"assignment_id"`
	Description  string     `gorm:"" json:"description"`
	Points       uint32     `gorm:"not null" json:"points"`
	Questions     []Question `json:"questions"`
	CreatedAt    time.Time  `gorm:"" json:"created_at"`
}

type Question struct {
	AssignmentID uint32 `gorm:"primary_key;auto_increment" json:"assignment_id"`
	Question   string `gorm:"" json:"question"`
	Option1    string `gorm:"" json:"option1"`
	Option2    string `gorm:"" json:"option2"`
	Option3    string `gorm:"" json:"option3"`
	Option4    string `gorm:"" json:"option4"`
	Answer     uint32 `gorm:"" json:"answer"`
}

type StudentAssignment struct {
	AssignmentID uint32 `gorm:"not null" json:"assignment_id"`
	StudentID    uint32 `gorm:"not null" json:"student_id"`
}
