package models

import (
	"api/security"
	"html"
	"log"
	"strings"
	"time"
)

//User is a struct
type User struct {
	ID        uint32    `gorm:"primary_key;auto_increment" json:"id"`
	UserName  string    `gorm:"size:255;not null;unique" json:"username"`
	Email     string    `gorm:"size:50;not null;unique" json:"email"`
	Password  string    `gorm:"size:60;not null" json:"password"`
	CreatedAt time.Time `gorm:"" json:"created_at"`
	LastLogin time.Time `gorm:"" json:"last_login"`
	LoginType string    `gorm:"" json:"login_type"`
}

//BeforeSave is a func to check password and hash password
func (u *User) BeforeSave() error {
	hashedPassword, err := security.Hash(u.Password)
	if err != nil {
		log.Fatal("error comes : ", err)
	}

	u.Password = string(hashedPassword)
	return nil
}

//Prepare is a func to eliminate the spaces in email and username
func (u *User) Prepare() {
	u.UserName = html.EscapeString(strings.TrimSpace(u.UserName))
	u.Email = html.EscapeString(strings.TrimSpace(u.Email))
}
