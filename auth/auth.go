package auth

import (
	"api/database"
	"api/models"
	"api/security"
	"api/utils/channels"
)

//SignIn is func to check password's hash to password by user
func SignIn(email, password string) (string, error) {
	user := models.User{}
	var err error
	db := database.DB
	done := make(chan bool)

	go func(ch chan<- bool) {
		defer close(ch)
		// db, err = database.Connect()
		// if err != nil {
		// 	ch <- false
		// 	return
		// }
		// defer db.Close()
		err = db.Debug().Model(models.User{}).Where("email = ?", email).Take(&user).Error
		if err != nil {
			ch <- false
			return
		}
		err = security.VerifyPassword(user.Password, password)
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)

	if channels.OK(done) {
		return CreateToken(user.ID)
	}
	return "", err

}
