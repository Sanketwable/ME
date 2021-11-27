package repository

import "api/models"

type AssignmentRepository interface {
	SaveFileAssigment(models.Assignment, models.FileAssignment) (models.Assignment, error)
	SaveFormAssigment(models.Assignment, models.FormAssignment, []models.Question) (models.Assignment, error)
	FindAssignment(uint32) ([]models.Assignment, error)
	FindFileAssignment(assignmentID uint32) (models.FileAssignment, error)
	FindFormAssignment(assignmentID uint32) (models.FormAssignment, error)
	GetAssignmentStatus(uint32, uint32) (models.StudentAssignment, error) 
	SaveAssignmentStatus(models.StudentAssignment) (models.StudentAssignment, error) 
}
