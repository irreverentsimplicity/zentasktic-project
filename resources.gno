package zentasktic_project

import (
	"strconv"
	"errors"

	"gno.land/p/demo/avl"
)

type Resource struct {
    Id 			string `json:"resourceId"`
    Name        string `json:"resourceName"`   // money / fixed expenses etc
}

var {
	Resources avl.Tree // r.Id -> r
	ResourceTasks avl.Tree // r.id -> []Tasks
	ResourceProjects avl.Tree // r.id -> []Projects
}

func (r Resource) AddResource() (err errors) { 

}

func (r Resource) RemoveResource() (err errors) { 

}

func (r Resource) AddResourceToTask(taskId string) (err errors) { 

}

func (r Resource) AddResourceToProject(projectId string) (err errors) { 

}

func (r Resource) RemoveResourceFromTask(taskId string) (err errors) { 

}

func (r Resource) RemoveResourceFromProject(projectId string) (err errors) { 

}

// getters

func GetResourcesByObjectId(objectId string, objectType string) (r []Resource, err errors) {
	// used for both Tasks and Projects, iterate over ResourceTasks, ResourceProjects
	// an object may have multiple types of resources assigned
}

func GetAllResources() (resources string, err errors){
	// marshalled into JSON
}