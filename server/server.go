package server

import (
	"api/auto"
	"api/config"
	"api/router"
	"fmt"
	"log"
	"net/http"
	"os"
)

func Run() {
	config.Load()
	fmt.Println("config file loaded")
	auto.Load()
	fmt.Println("DB loaded")
	fmt.Printf("\n\tListening.......[::]:%d \n", config.PORT)
	Listen(config.PORT)
}

func Listen(port int) {
	r := router.New()
	portt := os.Getenv("PORT")
	err := http.ListenAndServe(fmt.Sprintf(":%s", portt), r)
	if err != nil {
		log.Fatal("error is : ", err)
	}
}
