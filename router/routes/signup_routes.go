package routes

import (
	"api/controllers"
	"net/http"
)

// SignUpRoutes is a route
var SignUpRoutes = []Route {
	{
		Uri: "/signup",
		Method: http.MethodPost,
		Handler: controllers.SignUp,
		AuthRequired: false,
	},
}