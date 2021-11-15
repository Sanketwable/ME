package security

import "golang.org/x/crypto/bcrypt"
//Hash is used to produce hash
func Hash(password string) ([]byte, error) {
	return bcrypt.GenerateFromPassword([]byte(password),bcrypt.DefaultCost)

}
//VerifyPassword is used to verify the pasoword hash
func VerifyPassword(hashedPassword, password string) error {
	 return bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(password))
}