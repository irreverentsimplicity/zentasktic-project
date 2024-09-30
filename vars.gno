package zentasktic_project

import (
	"gno.land/p/demo/avl"
	"gno.land/p/demo/zteams"
	"std"
)

// Initialize global variables
var (
	Actors         *avl.Tree        // a.id -> a
	Tasks          *avl.Tree        // task.id -> task
	Projects       *avl.Tree        // p.id -> project
	ActorProjects  *avl.Tree        // a.id -> []*Project
	ActorTasks     *avl.Tree        // a.id -> []*Task
	TeamProjects   *avl.Tree        // team.id -> []*Project
	TeamTasks      *avl.Tree        // team.id -> []*Task
	WorkDurations  *avl.Tree        // wd.id -> wd
	RewardsPoints  *avl.Tree        // rp.id -> rp
	TeamManager    *zteams.TeamManager // Global TeamManager instance

	// Global map to associate user address with actor ID
	ActorIDMap     map[std.Address]string
)

func init() {
	// Initialize AVL Trees
	Actors = avl.NewTree()
	Tasks = avl.NewTree()
	Projects = avl.NewTree()
	ActorTasks = avl.NewTree()
	ActorProjects = avl.NewTree()
	TeamTasks = avl.NewTree()
	TeamProjects = avl.NewTree()
	WorkDurations = avl.NewTree()
	RewardsPoints = avl.NewTree()
	
	// Initialize TeamManager
	TeamManager = zteams.NewTeamManager()

	// Initialize the ActorIDMap
	ActorIDMap = make(map[std.Address]string)
}
