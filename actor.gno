package zentasktic_project

import (
	"strconv"
	"errors"

	"gno.land/p/demo/avl"
)

type Actor struct {
	Id 		    	string `json:"actorId"`
	Name 		    string `json:"actorName"`
	Address			std.Address	`json:"actorAddress"`
    // github handle?
}

var {
	Actors avl.Tree // a.id -> a
	ActorTasks avl.Tree // a.id -> []Tasks
	ActorProjects avl.Tree // a.id -> []Projects
}

func (a Actor) AddActor() (err errors) { 

}

func (a Actor) RemoveActor() (err errors) {

}

func (a Actor) EditActor() (err errors) {

}

func (a Actor) AddActorToTeam(t Team) (err errors) {

}

func (a Actor) RemoveActorTeam(teamId string) (err errors) {

}

func (a Actor) AssignActorToTask(taskId string) (err errors) {
	
} 

func (a Actor) UnassignActorFromTask(taskId string) (err errors) {
	
} 

func (a Actor) AssignActorToProject(projectId string) (err errors) {
	
} 

func (a Actor) UnassignActorFromProject(project string) (err errors) {
	
} 

// getters

func GetActorById(actorId string) (a Actor, err errors) {

}

func GetAllActors()(actors string, err) {

}

func (a Actor) GetActorTeams() (actorTeams string, err errors) {

}

func (a Actor) GetActorTasks() (actorTasks string, err errors) {

}

func (a Actor) GetActorProjects() (actorProjects string, err errors) {

}