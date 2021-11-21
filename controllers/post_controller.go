package controllers

import (
	"api/auth"
	"api/database"
	"api/models"
	"api/repository"
	"api/repository/crud"
	"api/responses"
	"encoding/json"
	"io/ioutil"
	"net/http"
	"strconv"
	"time"
)

func CreatePost(w http.ResponseWriter, r *http.Request) {
	faculty_id, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}

	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	post := models.Post{}
	err = json.Unmarshal(body, &post)
	post.UserID = faculty_id
	post.Time = time.Now().String()[:20]

	db, err := database.Connect()
	if err != nil {
		responses.ERROR(w, http.StatusInternalServerError, err)
		return
	}
	defer db.Close()

	repo := crud.NewRepositoryPostCRUD(db)

	func(postRepository repository.PostRepository) {
		post, err = postRepository.SavePost(post)
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, post)
	}(repo)

}
func CreateComment(w http.ResponseWriter, r *http.Request) {
	user_id, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}

	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		responses.ERROR(w, http.StatusUnprocessableEntity, err)
		return
	}
	comment := models.Comment{}
	err = json.Unmarshal(body, &comment)
	comment.Time = time.Now().String()[:20]
	comment.UserID = user_id

	db, err := database.Connect()
	if err != nil {
		responses.ERROR(w, http.StatusInternalServerError, err)
		return
	}
	defer db.Close()

	repo := crud.NewRepositoryPostCRUD(db)

	func(postRepository repository.PostRepository) {
		comment, err = postRepository.SaveComment(comment)
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, comment)
	}(repo)
}

func GetPosts(w http.ResponseWriter, r *http.Request) {
	_, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}

	classid := r.URL.Query().Get("class_id")
	class_id, err := strconv.Atoi(classid)	
	posts := []models.Post{}
	db, err := database.Connect()
	if err != nil {
		responses.ERROR(w, http.StatusInternalServerError, err)
		return
	}
	defer db.Close()

	repo := crud.NewRepositoryPostCRUD(db)

	func(postRepository repository.PostRepository) {
		posts, err = postRepository.FindPosts(uint32(class_id))
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, posts)
	}(repo)
}

func GetComments(w http.ResponseWriter, r *http.Request) {
	_, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}

	postid := r.URL.Query().Get("post_id")
	post_id, err := strconv.Atoi(postid)	
	comments := []models.Comment{}
	db, err := database.Connect()
	if err != nil {
		responses.ERROR(w, http.StatusInternalServerError, err)
		return
	}
	defer db.Close()

	repo := crud.NewRepositoryPostCRUD(db)

	func(postRepository repository.PostRepository) {
		comments, err = postRepository.FindComments(uint32(post_id))
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, comments)
	}(repo)
}
