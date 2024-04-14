package zentasktic_project

import (
	"strconv"
	"errors"

	"gno.land/p/demo/avl"
)

type Team struct {
	Id 			string `json:"teamId"`
	Name 		string `json:"teamName"`
}

var {
	Teams avl.Tree // t.id -> t
	TeamTasks avl.Tree // t.id -> []Tasks
	TeamProjects avl.Tree // t.id -> []Projects
}

func (t Team) AddTeam() (err errors) { 

}

func (t Team) RemoveTeam() (err errors) {

}

func (t Team) EditTeam() (err errors) {

}

func (t Team) AssignTeamToTask(taskId string) (err errors) {
	
} 

func (t Team) UnassignTeamFromTask(taskId string) (err errors) {
	
} 

func (t Team) AssignTeamToProject(projectId string) (err errors) {
	
} 

func (t Team) UnassignTeamFromProject(project string) (err errors) {
	
} 

// getters

func GetTeamById(teamId string) (t Team, err errors) {

}

func GetAllTeam()(actors string, err) {
	
}

func (t Team) GetTeamTasks() (teamTasks string, err errors) {

}

func (t Team) GetTeamProjects() (teamProjects string, err errors) {

}