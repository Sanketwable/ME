package config

import (
	"fmt"
	"log"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

var (
	//PORT is port to which it has to be connected
	PORT                = 0
	SECRETKEY           []byte
	DBURL               = ""
	DBDRIVER            = ""
	DBPORT              = ""
	STOREURL            []byte
	FROM_EMAIL          = ""
	FROM_EMAIL_PASSWORD = ""
	HOST                = ""
	ADDRESS             = ""
	TWILIOACCOUNTSID    = ""
	TWILIOAUTHTOKEN     = ""
	API_ADDRESS         = ""
	ZOOM_API_KEY        = ""
	ZOOM_API_SECRET     = ""
	ZOOM_EMAIL          = ""
	HEROKUURL           = ""
)

// Load is a func to load config variables
func Load() {
	var err error

	err = godotenv.Load()
	if err != nil {
		log.Fatal("Error is : ", err)
	}
	PORT, err = strconv.Atoi(os.Getenv("API_PORT"))
	if err != nil {
		PORT = 8080
	}
	API_ADDRESS = os.Getenv("API_ADDRESS")
	if API_ADDRESS == "" {
		API_ADDRESS = "localhost"
	}

	DBDRIVER = os.Getenv("DB_DRIVER")
	DBPORT = os.Getenv("DB_PORT")
	DBURL = fmt.Sprintf("%s:%s@(%s:%s)/%s?charset=utf8&parseTime=True&loc=Local", os.Getenv("DB_USER"), os.Getenv("DB_PASS"), os.Getenv("DB_HOST"), os.Getenv("DB_PORT"), os.Getenv("DB_NAME"))

	SECRETKEY = []byte(os.Getenv("API_SECRET"))
	STOREURL = []byte(os.Getenv("STORE_URL"))

	TWILIOACCOUNTSID = (os.Getenv("TWILIOACCOUNTSID"))
	TWILIOAUTHTOKEN = (os.Getenv("TWILIOAUTHTOKEN"))

	FROM_EMAIL = (os.Getenv("FROM_EMAIL"))
	FROM_EMAIL_PASSWORD = os.Getenv("FROM_EMAIL_PASSWORD")
	HOST = os.Getenv("HOST")
	ADDRESS = os.Getenv("ADDRESS")

	ZOOM_API_KEY = (os.Getenv("ZOOM_API_KEY"))
	ZOOM_API_SECRET = (os.Getenv("ZOOM_API_SECRET"))
	ZOOM_EMAIL = (os.Getenv("ZOOM_EMAIL"))
	HEROKUURL = os.Getenv("HEROKUURL")

}
