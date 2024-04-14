package zentasktic_project

import (
	"strconv"
	"errors"

	"gno.land/p/demo/avl"
)

type WorkHour struct {
	Id					string `json:"workHourId"`
    ObjectId 			string `json:"objectId"`
    ObjectType       string `json:"objectType"` // Task, Project
	Amount  		string `json:"workHourAmount"`
}

var {
	WorkHours avl.Tree // wh.Id -> wh
}

func (wh Workhour) AddWorkHours() (err errors) { 

}

func (wh Workhour) RemoveWorkHours() (err errors) { 

}

// getters

func GetWorkHoursByOjectId(objectId string, objectType string) (wh WorkHour, err errors) {

}

func GetAllWorkHours() (workHours int, err errors){

}