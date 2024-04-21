package zentasktic_project

import (
	"strconv"
	"errors"
	"time"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/zentasktic"
)

type Workable interface {
	// restrict implementation of Workable to this realm
	assertWorkable()
}

type isWorkable struct {}

type WorkableTask struct {
    zentasktic.Task
}

func (wt *WorkableTask) assertWorkable() {}

type WorkableProject struct {
    zentasktic.Project
}

func (wp *WorkableProject) assertWorkable() {}

var _ Workable = &WorkableTask{}
var _ Workable = &WorkableProject{}

type WorkDuration struct {
	Id				string `json:"workHourId"`
    ObjectId 		string `json:"objectId"`
    ObjectType      string `json:"objectType"` // Task, Project
	Duration  		time.Duration `json:"workDuration"`
	Workable   		Workable      `json:"-"`
}

var {
	WorkDurations avl.Tree // wd.Id -> wd
}

func (wd WorkDuration) AddWorkDuration() (err errors) { 
	WorkDurations.Set(wd.Id, wd)
	return nil
}

func (wd WorkDuration) RemoveWorkDuration() (err errors) { 
	// implementation
	existingWorkDuration := WorkDuration{}
	if WorkDurations.Size() != 0 {
		existingWorkDuration, exist := WorkDurations.Get(wd.Id)
		if !exist {
			return ErrWorkDurationNotFound
		}
	}
	
	_, removed := WorkDurations.Remove(existingWorkDuration.Id)
	if !removed {
		return ErrTaskNotRemoved
	}
	return nil
}

// getters

func GetWorkDurationByOjectId(objectId string, objectType string) (wd WorkDuration, err errors) {
	// implementation
	workDuration := WorkDuration{}

	// Iterate over the WorkDuration AVL tree to see if we have a matching ObjectId.
	
	WorkDurations.Iterate("", "", func(key string, value interface{}) bool {
		if workDurationItem, ok := value.(WorkDuration); ok {
			if workDurationItem.ObjectId == objectId && workDurationItem.ObjectType == objectType {
				workDuration = workDurationItem
			}
		}
		return false // Continue iteration until all nodes have been visited.
	})

	return workDuration, nil
}

func GetAllWorkDurations() (workDurations []WorkDuration, err errors){

}