package routes

import (
	"api/controllers"
	"net/http"
)

var facultyRoutes = []Route{
	{
		Uri:          "/facultyinfo",
		Method:       http.MethodPost,
		Handler:      controllers.CreateFacultyInfo,
		AuthRequired: true,
	},
	{
		Uri:          "/facultyinfo",
		Method:       http.MethodGet,
		Handler:      controllers.GetFacultyInfo,
		AuthRequired: true,
	},
	{
		Uri:          "/facultyinfo",
		Method:       http.MethodPut,
		Handler:      controllers.UpdateFacultyInfo,
		AuthRequired: true,
	},
}
