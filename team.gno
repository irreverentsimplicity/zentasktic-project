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

var {
	Teams avl.Tree // t.id -> t
	Members	avl.Tree // t.id -> []*Actor
	TeamTasks avl.Tree // t.id -> []*Tasks
	TeamProjects avl.Tree // t.id -> []*Projects
}

func (t Team) AddTeam() (err errors) { 
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

func (t Team) RemoveTeam() (err errors) {
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

func (t Team) EditTeam() (err errors) {
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
	// implementation
	if Teams.Size() != 0 {
		team, exist := Teams.Get(teamId)
		if exist {
			return team.(Team), nil
		} else {
			retrun nil, ErrTeamIdNotFound
		}

	}
	return nil, ErrTeamIdNotFound
}

func GetAllTeams()(teams string, err) {
	// implementation
	var allTeams []Team

	// Iterate over the Teams AVL tree to collect all Team objects.
	Teams.Iterate("", "", func(key string, value interface{}) bool {
		if team, ok := value.(Team); ok {
			allTeams = append(allTeams, team)
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

func (t Team) GetTeamTasks() (teamTasks string, err errors) {

}

func (t Team) GetTeamProjects() (teamProjects string, err errors) {

}