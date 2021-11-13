package routes

import (
	"api/controllers"
	"net/http"
)

var studentRoutes = []Route{
	{
		Uri:          "/studentinfo",
		Method:       http.MethodPost,
		Handler:      controllers.CreateStudentInfo,
		AuthRequired: true,
	},
	{
		Uri:          "/studentinfo",
		Method:       http.MethodGet,
		Handler:      controllers.GetStudentInfo,
		AuthRequired: true,
	},
	{
		Uri:          "/studentinfo",
		Method:       http.MethodPut,
		Handler:      controllers.UpdateStudentInfo,
		AuthRequired: true,
	},
}
