package database

import (
	"api/config"
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/mysql"
)

// DB is database connection
var DB *gorm.DB

// Connect is func to connect to DB
func DBConnect() (*gorm.DB, error) {
	var err error
	DB, err = gorm.Open(config.DBDRIVER, config.DBURL)
	if err != nil {
		return nil, err
	}
	return DB, nil

}
