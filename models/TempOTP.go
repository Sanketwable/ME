package models

import (
	"time"
)

// TempOTP is a struct
type TempOTP struct {
	TempOTPID uint32    `gorm:"primary_key;auto_increment" json:"temp_otp_id"`
	Email     string    `gorm:"primary_key;size:255;not null" json:"email"`
	OTP       string    `gorm:"size:255;not null" json:"otp"`
	CreatedAt time.Time `gorm:"" json:"created_at"`
	ExpiresAt time.Time `gorm:"" json:"expires_at"`
	Verified  bool      `gorm:"Type:bool;default:false" json:"verified"`
}
