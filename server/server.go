package server

import (
	"api/auto"
	"api/config"
	"api/router"
	"fmt"
	"log"
	"net/http"
)

// Run is used to start the server
func Run() {
	config.Load()
	fmt.Println("config file loaded")
	auto.Load()
	fmt.Println("DB loaded")
	fmt.Printf("\n\tListening.......[::]:%d \n", config.PORT)
	Listen(config.PORT)
}

// Listen is used to make server run on partucular port
func Listen(port int) {
	r := router.New()
	// portt := os.Getenv("PORT")
	err := http.ListenAndServe(fmt.Sprintf(":%d", port), r)
	if err != nil {
		log.Fatal("error is : ", err)
	}
}
