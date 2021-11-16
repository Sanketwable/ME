package routes

import (
	"api/controllers"
	"net/http"
)

var classesRoutes = []Route {
	 {
		Uri: "/getclass",
		Method: http.MethodGet,
		Handler: controllers.GetClass,
		AuthRequired: true,
	},
	{
		Uri: "/getclasses",
		Method: http.MethodGet,
		Handler: controllers.GetClasses,
		AuthRequired: true,
	},
	{
		Uri: "/createclass",
		Method: http.MethodPost,
		Handler: controllers.CreateClass,
		AuthRequired: true,
	},
	{
		Uri: "/addstudent",
		Method: http.MethodGet,
		Handler: controllers.AddClassWithEmail,
		AuthRequired: true,
	},
	{
		Uri: "/addclass",
		Method: http.MethodGet,
		Handler: controllers.AddClassWithClassCode,
		AuthRequired: true,
	},
}