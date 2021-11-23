package routes

import (
	"api/controllers"
	"api/middlewares"
	"net/http"

	"github.com/gorilla/mux"
)

// Route is a struct that stores all the parameter of an endpoint
type Route struct {
	Uri          string
	Method       string
	Handler      func(http.ResponseWriter, *http.Request)
	AuthRequired bool
}

var verifyRoute = Route {
	Uri: "/verifymobile",
	Method: http.MethodGet,
	Handler: controllers.VerifyMobile,
	AuthRequired: false,
}

// Load is  a func to create array of all the routes
func Load() []Route {
	routes := usersRoutes
	routes = append(routes, studentRoutes...)
	routes = append(routes, facultyRoutes...)
	routes = append(routes, loginRoutes...)
	routes = append(routes, SignUpRoutes...)
	routes = append(routes, ForgetPasswordRoutes...)
	routes = append(routes, classesRoutes...)
	routes = append(routes, verifyRoute)
	routes = append(routes, assignmentRoutes...)
	routes = append(routes, postsRoutes...)
	routes = append(routes, messageRoute...)
	return routes
}

//SetUpRoutes is a func to set all the routes from the Route array
func SetUpRoutes(r *mux.Router) *mux.Router {

	for _, route := range Load() {
		r.HandleFunc(route.Uri, route.Handler).Methods(route.Method)
	}
	return r
}

//SetUpRoutesWithMiddlewares is  a func to add all the created middlewares
func SetUpRoutesWithMiddlewares(r *mux.Router) *mux.Router {

	for _, route := range Load() {
		if route.AuthRequired {
			r.HandleFunc(route.Uri,
				middlewares.SetMiddlewareLogger(
					middlewares.SetMiddlewareJSON(
						middlewares.SetMiddlewareAuthentication(route.Handler)))).Methods(route.Method)

		} else {
			r.HandleFunc(route.Uri, middlewares.SetMiddlewareLogger(middlewares.SetMiddlewareJSON(route.Handler))).Methods(route.Method)
		}
	}
	return r
}
