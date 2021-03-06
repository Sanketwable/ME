package controllers

import (
	"api/config"
	"fmt"

	"gopkg.in/gomail.v2"
)

// SendOTPEmail is a func
func SendOTPEmail(to string, otp string, subject string) error {

	fromEmail := config.FROM_EMAIL
	fromEmailPassword := config.FROM_EMAIL_PASSWORD
	host := config.HOST

	m := gomail.NewMessage()
	m.SetHeader("From", fromEmail)
	m.SetHeader("To", to)
	m.SetAddressHeader("Cc", to, "User")
	m.SetHeader("Subject", subject)
	m.SetBody("text/html",
		`
		   <p style="text-align: center; font-size: 40px;"><span style="color: #666699;">Study</span></p>
		   <hr />
		   <div style="text-align: center;"><span style="color: #333300;">OTP Verification Code</span></div>
		   <div>Hello,</div>
		   <div>&nbsp; &nbsp;Please enter the below code to complete verification:</div>
		   <div style="text-align: center; font-size: 40px;"><strong>`+otp+`</strong></div>
		   <div>&nbsp;</div>
		   <div><span style="color: #999999; font-size: 10px;">Valid for the next 30 minutes</span></div>
		   
		   <div>
		   <p>&nbsp;</p>
		   <p>&nbsp;</p>
		   <table style="border-color: rgba(0, 0, 0, 0); width: 700px; height: 40px; margin-left: auto; margin-right: auto;">
		   <tbody>
		   <tr>
		   <td style="width: 329px;">
		   <p><strong>Connect with us:</strong></p>
		   <p><a title="facebook" href="https:facebook.com" target="_blank" rel="noopener" data-saferedirecturl="https://www.google.com/"><img class="CToWUd" src="https://ci3.googleusercontent.com/proxy/N0peHDQYmnamNIxB3VYP20-_LJmivn_2wKrNv_XXZt-fEOGIS0_04JcD-Ci3jkJYiNjJuQBVjjZLZzzLQpejeIhmY9rGG005U2JhBsD2kz3gj3YhmddWdg=s0-d-e1-ft#https://s3.ap-south-1.amazonaws.com/dev-pm-static/app/emailers/fb.png" alt="" width="30" height="30" /></a>&nbsp;<a href="https://bit.ly/2zHdHPp" target="_blank" rel="noopener" data-saferedirecturl="https://www.google.com/url?q=https://bit.ly/2zHdHPp&amp;source=gmail&amp;ust=1598633546253000&amp;usg=AFQjCNHtau893a7exXBwkjDs9aQLyfzEOw"><img class="CToWUd" src="https://ci3.googleusercontent.com/proxy/X8p8a0kqFIyQUQTrUWXOvkx8ISYX3uhieygZ2CAKhBApSXNGHoK79QpVVjmJBrQhpvItSvMruZ1pUG7uGlgFoiAxKICILxdrNjG5G3sDrK6SIXuGUrND_g=s0-d-e1-ft#https://s3.ap-south-1.amazonaws.com/dev-pm-static/app/emailers/tw.png" alt="" width="30" height="30" /></a>&nbsp;<a href="https://bit.ly/2uDSaBk" target="_blank" rel="noopener" data-saferedirecturl="https://www.google.com/url?q=https://bit.ly/2uDSaBk&amp;source=gmail&amp;ust=1598633546253000&amp;usg=AFQjCNHu32ebwi_aF0OCDpGcW-PaeKgEbg"><img class="CToWUd" src="https://ci6.googleusercontent.com/proxy/7bzp2Qj7y-jYLeEZCmriK4rzDig4LXa3kO5Z0BbXbdAOk7w3cnS1kbQPVYhOy5afuRRDgJY1w1FcT2Mj2QxLwtlwf387-hOT5HxAwZrI4uzn8oJuB6JDxA=s0-d-e1-ft#https://s3.ap-south-1.amazonaws.com/dev-pm-static/app/emailers/li.png" alt="" width="30" height="30" /></a>&nbsp;<a href="https://bit.ly/2zJ7D9h" target="_blank" rel="noopener" data-saferedirecturl="https://www.google.com/url?q=https://bit.ly/2zJ7D9h&amp;source=gmail&amp;ust=1598633546253000&amp;usg=AFQjCNEv50cZrA6C90sF0rvnw1D4i9n46A"><img class="CToWUd" src="https://ci4.googleusercontent.com/proxy/8qPa1tpJoIPt1ACQRgXLwzo3MExJChHZfkhutrdfsiK8lS9oDM5yR2d_-ocCSxjEfVlfrqe15OxBnleQYy2tIiX8Y3GUWBmMYiYsDd39QQ_A7gCTU1O5ESfTtZ4=s0-d-e1-ft#https://s3.ap-south-1.amazonaws.com/dev-pm-static/app/emailers/medium.png" alt="" width="30" height="30" /></a></p>
		   </td>
		   <td style="width: 349px;">
		   </td>
		   </tr>
		   </tbody>
		   </table>
		   </div>`)

	d := gomail.NewDialer(host, 587, fromEmail, fromEmailPassword)
	if err := d.DialAndSend(m); err != nil {
		fmt.Println(err)
		return err
	}

	fmt.Println("OTP Email Sent")
	return nil
}
