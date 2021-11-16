package models

// Qualification detail about faculties
type Qualification struct {
	UserID uint32 `gorm:"not null;unique" json:"id"`
	Degree string `gorm:"not null;" json:"degree"`
	PassoutYear   string `gorm:"" json:"passout_year"`
}


//FacultyInfo stores sone basic information about faculty
type FacultyInfo struct {
	UserID        uint32        `gorm:"not null;unique" json:"id"`
	FirstName     string        `gorm:"size:30;not null;" json:"first_name"`
	LastName      string        `gorm:"size:30;not null;" json:"last_name"`
	PhoneNo       string        `gorm:"size:30;not null;" json:"phone_no"`
	Qualification Qualification `json:"qualification"`
	ProfilePhoto  string        `gorm:"" json:"profile_photo"`
	Experience    float32       `gorm:"" json:"experience"`
	OTPVerified   bool          `gorm:"default:false;" json:"otp_verified"`
}

// StudentInfo stores some basic informatin about student
type StudentInfo struct {
	UserID       uint32  `gorm:"not null;unique" json:"id"`
	FirstName    string  `gorm:"size:30;not null;" json:"first_name"`
	LastName     string  `gorm:"size:30;not null;" json:"last_name"`
	Year         uint32  `gorm:"" json:"year"`
	PhoneNo      string  `gorm:"size:30;not null;" json:"phone_no"`
	ProfilePhoto string  `gorm:"" json:"profile_photo"`
	OTPVerified  bool    `gorm:"default:false;" json:"otp_verified"`
}
