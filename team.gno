package zentasktic_project

import (
	"strconv"
	"errors"

	"gno.land/p/demo/avl"
)

type Team struct {
	Id 			string `json:"teamId"`
	Name 		string `json:"teamName"`
	Members		[]*Actor `json:"teamMembers"`
}

var (
	Teams avl.Tree // t.id -> t
	Members	avl.Tree // t.id -> []*Actor
	TeamTasks avl.Tree // t.id -> []*WorkableTask
	TeamProjects avl.Tree // t.id -> []*WorkableProject
)

func (t Team) AddTeam() (err error) { 
	// implementation
	
	if Teams.Size() != 0 {
		existingTeams, exist := Teams.Get(t.Id)
		if exist {
			return ErrTeamIdAlreadyExists
		}
	}
	Teams.Set(t.Id, t)
	return nil

}

func (t Team) RemoveTeam() (err error) {
	// implementation
	existingTeam := Team{}
	if Teams.Size() != 0 {
		existingTeam, exist := Teams.Get(t.Id)
		if !exist {
			return ErrTeamIdNotFound
		}
	}
	
	// if team has members, remove it from the Members avl.Tree
	if Members.Size() != 0 {
		existingTeamMembers, exist := Members.Get(t.Id)
		if exist {
			_, removed := Members.Remove(t.Id)
			if !removed {
				return ErrTeamMembersNotRemoved
			}
		}
	}

	// if Team has tasks assigned, unassign from them
	if TeamTasks.Size() != 0 {
		existingTeamTasks, exist := TeamTasks.Get(t.Id)
		if exist {
			_, removed := TeamTasks.Remove(t.Id)
			if !removed {
				return ErrTeamTasksNotRemoved
			}
		}
	}

	// if team has projects assigned, unassign from them
	if TeamProjects.Size() != 0 {
		existingTeamProjects, exist := TeamProjects.Get(t.Id)
		if exist {
			_, removed := TeamProjects.Remove(t.Id)
			if !removed {
				return ErrTeamProjectsNotRemoved
			}
		}
	}

	// remove team
	_, removed := Teams.Remove(t.Id)
	if !removed {
		return ErrTeamNotRemoved
	}
	return nil

}

func (t Team) EditTeam() (err error) {
	// implementation, get team by Id and replace the object
	existingTeam := Team{}
	if Teams.Size() != 0 {
		existingTeam, exist := Teams.Get(t.Id)
		if !exist {
			return ErrTeamIdNotFound
		}
	}
	
	Teams.Set(t.Id, t)
	return nil
}
/*
func (t Team) AssignTeamToTask(wt WorkableTask) (err error) {
	if TeamTasks.Size() != 0 {
		existingWorkableTasks, ok := TeamTasks.Get(t.Id)
		if !ok {
			existingWorkableTasks = []*WorkableTask{}
		} else {
			tasks, ok := existingWorkableTasks([]*WorkableTask)
			if !ok {
				return ErrTeamTasksNotFound
			}
			existingWorkableTasks = tasks
		}
		updatedTasks := append(existingWorkableTasks.([]*WorkableTask), wt)
		TeamTasks.Set(t.Id, updatedTasks)
	}
	return nil
} 

func (t Team) UnassignTeamFromTask(wt WorkableTask) (err error) {
	if TeamTasks.Size() != 0 {
		existingTeamTasks, exist := TeamTasks.Get(t.Id)
		if exist {

			var tindex int = -1
			for i, task := range existingTeamTasks.([]*WorkableTask) {
				if wt.id == task.id {
					tindex = i
					break
				}
				if tindex != -1 {
					existingTeamTasks = append(existingTeamTasks.([]*WorkableTask)[:tindex], existingTeamTasks.([]*WorkableTask)[tindex+1:]...)
				} else {
					// Team tasks not found in the TeamTasks tree
					return ErrTeamTasksNotFound 
				}
				TeamTasks.Set(t.Id, existingTeamTasks)
			}
		} else {
			// Team tasks not found in the TeamTasks tree
			return ErrTeamTasksNotFound 
		}
	}
	return nil
} 

func (t Team) AssignTeamToProject(wp WorkableProject) (err error) {
	if TeamProjects.Size() != 0 {
		existingWorkableProjects, ok := TeamProjects.Get(t.Id)
		if !ok {
			existingWorkableProjects = []*WorkableProject{}
		} else {
			projects, ok := existingWorkableProjects([]*WorkableProject)
			if !ok {
				return ErrTeamProjectsNotFound
			}
			existingWorkableProjects = projects
		}
		updatedProjects := append(existingWorkableProjects.([]*WorkableProject), wp)
		TeamProjects.Set(t.Id, updatedProjects)
	}
	return nil
} 

func (t Team) UnassignTeamFromProject(wp WorkableProject) (err error) {
	if TeamProjects.Size() != 0 {
		existingTeamProjects, exist := TeamProjects.Get(t.Id)
		if exist {

			var tindex int = -1
			for i, project := range existingTeamProjects.([]*WorkableProject) {
				if wp.id == project.id {
					tindex = i
					break
				}
				if tindex != -1 {
					existingTeamProjects = append(existingTeamProjects.([]*WorkableProject)[:tindex], existingTeamProjects.([]*WorkableProject)[tindex+1:]...)
				} else {
					// Team projects not found in the TeamProjects tree
					return ErrTeamProjectsNotFound 
				}
				TeamProjects.Set(t.Id, existingActorProjects)
			}
		} else {
			// Team projects not found in the TeamProjects tree
			return ErrTeamProjectsNotFound 
		}
	}
	return nil
} */

// getters

func GetTeamById(teamId string) (t Team, err error) {
	// implementation
	if Teams.Size() != 0 {
		team, exist := Teams.Get(teamId)
		if exist {
			return team.(Team), nil
		} else {
			return nil, ErrTeamIdNotFound
		}

	}
	return nil, ErrTeamIdNotFound
}

func GetAllTeams()(teams string, err error) {
	// implementation
	var allTeams []*Team

	// Iterate over the Teams AVL tree to collect all Team objects.
	Teams.Iterate("", "", func(key string, value interface{}) bool {
		if team, ok := value.(Team); ok {
			allTeams = append(allTeams, &team)
		}
		return false // Continue iteration until all nodes have been visited.
	})

	// Create a TeamsObject with all collected team.
	teamsObject := &TeamsObject{
		Teams: allTeams,
	}

	// Use the custom MarshalJSON method to marshal the teams into JSON.
	marshalledTeams, merr := teamsObject.MarshalJSON()
	if merr != nil {
		return "", merr
	} 
	return string(marshalledTeams), nil
}

/*
func (t Team) GetTeamTasks() (teamTasks string, err error) {

}

func (t Team) GetTeamProjects() (teamProjects string, err error) {

}*/