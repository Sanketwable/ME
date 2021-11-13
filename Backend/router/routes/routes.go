package routes

import (
	"api/middlewares"
	"net/http"

	"github.com/gorilla/mux"
)

// Route is a struct
type Route struct {
	Uri          string
	Method       string
	Handler      func(http.ResponseWriter, *http.Request)
	AuthRequired bool
}

// Load is  a func
func Load() []Route {
	routes := usersRoutes
	routes = append(routes, studentRoutes...)
	routes = append(routes, facultyRoutes...)
	routes = append(routes, loginRoutes...)
	routes = append(routes, SignUpRoutes...)
	routes = append(routes, ForgetPasswordRoutes...)
	return routes
}

//SetUpRoutes is a func
func SetUpRoutes(r *mux.Router) *mux.Router {

	for _, route := range Load() {
		r.HandleFunc(route.Uri, route.Handler).Methods(route.Method)
	}
	return r
}

//SetUpRoutesWithMiddlewares is  a func
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
