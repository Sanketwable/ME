package routes

import (
	"api/controllers"
	"net/http"
)

// ForgetPasswordRoutes is a route
var ForgetPasswordRoutes = []Route {
	{
		Uri: "/forgetpassword",
		Method: http.MethodPost,
		Handler: controllers.ForgetPassword,
		AuthRequired: false,
	},
}