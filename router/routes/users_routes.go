package routes

import (
	"api/controllers"
	"net/http"
)

var usersRoutes = []Route {
	 {
		Uri: "/users",
		Method: http.MethodGet,
		Handler: controllers.GetUsers,
		AuthRequired: false,
	},
	{
		Uri: "/verifyuser",
		Method: http.MethodGet ,
		Handler: controllers.VerifyUser,
		AuthRequired: true,
	},
	// {
	// 	Uri: "/users/{id}",
	// 	Method: http.MethodGet,
	// 	Handler: controllers.GetUser,
	// 	AuthRequired: false,
	// },
	{
		Uri: "/updatepassword",
		Method: http.MethodPut,
		Handler: controllers.UpdatePassword,
		AuthRequired: true,
	},
	{
		Uri: "/user",
		Method: http.MethodDelete,
		Handler: controllers.DeleteUser,
		AuthRequired: false,
	},
}