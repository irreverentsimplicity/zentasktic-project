package zentasktic_project

import (
	"gno.land/p/demo/avl"
)

// Initialize global variables
var (
    Actors        	*avl.Tree // a.id -> a
    Teams         	*avl.Tree // team.id -> team
    Tasks         	*avl.Tree // task.id -> task
    Projects      	*avl.Tree // p.id -> project
	ActorProjects 	*avl.Tree // a.id -> []*Project
	ActorTasks		*avl.Tree // a.id -> []*Task
	TeamProjects	*avl.Tree // team.id -> []*Project
	TeamTasks		*avl.Tree // team.id -> []*Task
    WorkDurations 	*avl.Tree // wd.id -> wd
    RewardsPoints 	*avl.Tree // rp.id -> rp
)

func init() {
	Actors = avl.NewTree()
	Teams = avl.NewTree()
	Tasks = avl.NewTree()
	Projects = avl.NewTree()
	ActorTasks = avl.NewTree()
	ActorProjects = avl.NewTree()
	TeamTasks = avl.NewTree()
	TeamProjects = avl.NewTree()
    WorkDurations = avl.NewTree()
    RewardsPoints = avl.NewTree()
}
