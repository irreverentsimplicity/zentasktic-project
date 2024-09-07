package zentasktic_project

import (
	"std"
	"time"
	"gno.land/p/demo/zentasktic"
)

// zentasktic package wrapped types

type WorkableRealm struct {
	Id   string
	Name string
}

type WorkableContext struct {
	zentasktic.Context
}

type WorkableCollection struct {
	zentasktic.Collection
}

type WorkableObjectPath struct {
	zentasktic.ObjectPath
}

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

// zentasktic project specific types

type Actor struct {
	Id      string      `json:"actorId"`
	Name    string      `json:"actorName"`
	Address std.Address `json:"actorAddress"`
}

type Team struct {
	Id      string   `json:"teamId"`
	Name    string   `json:"teamName"`
	Members []*Actor `json:"teamMembers"`
}

type WorkDuration struct {
	Id				string `json:"workDurationId"`
    ObjectId 		string `json:"objectId"`
    ObjectType      string `json:"objectType"` // Task, Project
	Duration  		time.Duration `json:"workDuration"`
	Workable   		Workable      `json:"-"`
}

type RewardsPoint struct {
    Id				string `json:"rewardsPointId"`
    ObjectId 		string `json:"objectId"`
    ObjectType      string `json:"objectType"`
	Amount  		std.Coins `json:"rewardsPointAmount"`
    Status			string `json:"rewardsPointStatus"`            // assigned / released / unused, disbursed, etc
}

