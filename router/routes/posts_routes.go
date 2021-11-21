package routes

import (
	"api/controllers"
	"net/http"
)

var postsRoutes = []Route{
	{
		Uri:          "/getposts",
		Method:       http.MethodGet,
		Handler:      controllers.GetPosts,
		AuthRequired: true,
	},
	{
		Uri:          "/getcomments",
		Method:       http.MethodGet,
		Handler:      controllers.GetComments,
		AuthRequired: true,
	},
	{
		Uri:          "/createpost",
		Method:       http.MethodPost,
		Handler:      controllers.CreatePost,
		AuthRequired: true,
	},
	{
		Uri:          "/createcomment",
		Method:       http.MethodPost,
		Handler:      controllers.CreateComment,
		AuthRequired: true,
	},
}
