package console

import (
	"encoding/json"
	"fmt"
	"log"
)

func Pretty(data interface{}) {
	b, err := json.MarshalIndent(data, "", " ")
	if err != nil {
		log.Fatal("error  is : ", err)
		return
	}
	fmt.Println(string(b))

}