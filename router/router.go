package router

import (
	"api/router/routes"

	"github.com/gorilla/mux"
)

//New is function to create an new gorilla/mux router
func New() *mux.Router {
	r := mux.NewRouter().StrictSlash(true)
	return routes.SetUpRoutesWithMiddlewares(r)
}