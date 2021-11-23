package routes

import (
	"api/controllers"
	"net/http"
)

var messageRoute = []Route{
	{
		Uri: "/message",
		Method: http.MethodGet,
		Handler: controllers.GetMessages,
		AuthRequired: true,
	},
	{
		Uri: "/message",
		Method: http.MethodPost,
		Handler: controllers.AddMessages,
		AuthRequired: true,
	},

}