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
// PostsResponse is Response to server post request
type PostsResponse struct {
	PostID      uint32    `json:"post_id"`
	ClassID     uint32    `json:"class_id"`
	UserID      uint32    `json:"user_id"`
	FirstName   string    `json:"first_name"`
	LastName    string    `json:"last_name"`
	Description string    `json:"description"`
	Time        string    `json:"time"`
}

// CommentsResponse is a Response struct to server comment request
type CommentsResponse struct {
	PostID    uint32 `json:"post_id"`
	UserID    uint32 `json:"user_id"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Comment   string `json:"comment"`
	Time      string `json:"time"`
}

// CreatePost Func is a Handler Func to create new Post by faculty
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

	// db, err := database.Connect()
	// if err != nil {
	// 	responses.ERROR(w, http.StatusInternalServerError, err)
	// 	return
	// }
	// defer db.Close()

	repo := crud.NewRepositoryPostCRUD(database.DB)

	func(postRepository repository.PostRepository) {
		post, err = postRepository.SavePost(post)
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, post)
	}(repo)

}

// CreateComment is a Func to create comment on post
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

	// db, err := database.Connect()
	// if err != nil {
	// 	responses.ERROR(w, http.StatusInternalServerError, err)
	// 	return
	// }
	// defer db.Close()

	repo := crud.NewRepositoryPostCRUD(database.DB)

	func(postRepository repository.PostRepository) {
		comment, err = postRepository.SaveComment(comment)
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		responses.JSON(w, http.StatusOK, comment)
	}(repo)
}

// GetPosts is a func to get posts corresponding to class
func GetPosts(w http.ResponseWriter, r *http.Request) {
	_, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}

	classid := r.URL.Query().Get("class_id")
	class_id, err := strconv.Atoi(classid)	
	posts := []models.Post{}
	
	// db, err := database.Connect()
	// if err != nil {
	// 	responses.ERROR(w, http.StatusInternalServerError, err)
	// 	return
	// }
	// defer db.Close()

	repo := crud.NewRepositoryPostCRUD(database.DB)

	func(postRepository repository.PostRepository) {
		posts, err = postRepository.FindPosts(uint32(class_id))
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		postresponse := []PostsResponse{}
		for _, post := range posts {
			pr := PostsResponse{}
			pr.ClassID = post.ClassID
			pr.Description = post.Description
			pr.PostID = post.PostID
			pr.Time = post.Time
			repo1 := crud.NewRepositoryStudentInfoCRUD(database.DB)
			studentinfo, err := repo1.FindById(uint64(post.UserID))
			if err != nil {
				repo1 := crud.NewRepositoryFacultyInfoCRUD(database.DB)
				facultyinfo, _ := repo1.FindById(uint64(post.UserID))
				pr.FirstName = facultyinfo.FirstName
				pr.LastName = facultyinfo.LastName
			} else {
				pr.FirstName = studentinfo.FirstName
				pr.LastName = studentinfo.LastName
			}
			postresponse = append(postresponse, pr)
		}
		
		responses.JSON(w, http.StatusOK, postresponse)
	}(repo)
}

// GetComments function returns all the comments on posts
func GetComments(w http.ResponseWriter, r *http.Request) {
	_, err := auth.ExtractTokenID(r)
	if err != nil {
		responses.ERROR(w, http.StatusUnauthorized, err)
		return
	}

	postid := r.URL.Query().Get("post_id")
	post_id, err := strconv.Atoi(postid)	
	comments := []models.Comment{}
	commentresponse := []CommentsResponse{}
	// db, err := database.Connect()
	// if err != nil {
	// 	responses.ERROR(w, http.StatusInternalServerError, err)
	// 	return
	// }
	// defer db.Close()

	repo := crud.NewRepositoryPostCRUD(database.DB)

	func(postRepository repository.PostRepository) {
		comments, err = postRepository.FindComments(uint32(post_id))
		if err != nil {
			responses.ERROR(w, http.StatusUnprocessableEntity, err)
			return
		}
		for _, comment := range comments {
			c := CommentsResponse{}
			c.Comment = comment.Comment
			c.PostID = comment.PostID
			c.Time = comment.Time
			c.UserID = comment.UserID

			repo1 := crud.NewRepositoryStudentInfoCRUD(database.DB)
			studentinfo, err := repo1.FindById(uint64(comment.UserID))
			if err != nil {
				repo1 := crud.NewRepositoryFacultyInfoCRUD(database.DB)
				facultyinfo, _ := repo1.FindById(uint64(comment.UserID))
				c.FirstName = facultyinfo.FirstName
				c.LastName = facultyinfo.LastName
			} else {
				c.FirstName = studentinfo.FirstName
				c.LastName = studentinfo.LastName
			}
			commentresponse = append(commentresponse, c)
		}
		responses.JSON(w, http.StatusOK, commentresponse)
	}(repo)
}
