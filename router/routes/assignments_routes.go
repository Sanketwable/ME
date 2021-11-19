package routes

import (
	"api/controllers"
	"net/http"
)

var assignmentRoutes = []Route {
	 {
		Uri: "/getassignment",
		Method: http.MethodGet,
		Handler: controllers.GetAssignment,
		AuthRequired: true,
	},
	{
		Uri: "/createassignment",
		Method: http.MethodPost,
		Handler: controllers.CreateAssignment,
		AuthRequired: true,
	},
	{
		Uri: "/getfileassignment",
		Method: http.MethodGet,
		Handler: controllers.GetFileAssignment,
		AuthRequired: true,
	},
	{
		Uri: "/getformassignment",
		Method: http.MethodGet,
		Handler: controllers.GetFormAssignment,
		AuthRequired: true,
	},
}