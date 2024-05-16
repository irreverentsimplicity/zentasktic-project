package zentasktic_project

import (
	"strconv"
	"errors"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/zentasktic"
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

func (t Team) AssignTeamToTask(wt *WorkableTask) (err error) {
	if TeamTasks.Size() != 0 {
        existingWorkableTasks, ok := TeamTasks.Get(t.Id)
        if !ok {
            existingWorkableTasks = []*WorkableTask{}
        }
        
        tasks, ok := existingWorkableTasks.([]*WorkableTask)
        if !ok {
            return ErrTeamTasksNotFound
        }
        
        updatedTasks := append(tasks, wt)
        TeamTasks.Set(t.Id, updatedTasks)
    } else {
        TeamTasks.Set(t.Id, []*WorkableTask{wt})
    }
    return nil
} 

func (t Team) UnassignTeamFromTask(wt *WorkableTask) (err error) {
	if TeamTasks.Size() != 0 {
        existingTeamTasks, exist := TeamTasks.Get(t.Id)
        if !exist {
            return ErrTeamTasksNotFound
        }

        tasks, ok := existingTeamTasks.([]*WorkableTask)
        if !ok {
            return ErrTeamTasksNotFound
        }

        var tindex int = -1
        for i, task := range tasks {
            if wt.Id == task.Id {
                tindex = i
                break
            }
        }

        if tindex != -1 {
            updatedTasks := append(tasks[:tindex], tasks[tindex+1:]...)
            TeamTasks.Set(t.Id, updatedTasks)
        } else {
            return ErrTeamTasksNotFound
        }
    } else {
        return ErrTeamTasksNotFound
    }
    return nil
} 

func (t Team) AssignTeamToProject(wp *WorkableProject) (err error) {
	if TeamProjects.Size() != 0 {
        existingWorkableProjects, ok := TeamProjects.Get(t.Id)
        if !ok {
            existingWorkableProjects = []*WorkableProject{}
        }
        
        projects, ok := existingWorkableProjects.([]*WorkableProject)
        if !ok {
            return ErrTeamProjectsNotFound
        }
        
        updatedProjects := append(projects, wp)
        TeamProjects.Set(t.Id, updatedProjects)
    } else {
        TeamProjects.Set(t.Id, []*WorkableProject{wp})
    }
    return nil
} 

func (t Team) UnassignTeamFromProject(wp *WorkableProject) (err error) {
	if TeamProjects.Size() != 0 {
        existingTeamProjects, exist := TeamProjects.Get(t.Id)
        if !exist {
            return ErrTeamProjectsNotFound
        }

        projects, ok := existingTeamProjects.([]*WorkableProject)
        if !ok {
            return ErrTeamProjectsNotFound
        }

        var tindex int = -1
        for i, project := range projects {
            if wp.Id == project.Id {
                tindex = i
                break
            }
        }

        if tindex != -1 {
            updatedProjects := append(projects[:tindex], projects[tindex+1:]...)
            TeamProjects.Set(t.Id, updatedProjects)
        } else {
            return ErrTeamProjectsNotFound
        }
    } else {
        return ErrTeamProjectsNotFound
    }
    return nil
} 

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
func (t Team) GetTeamMembers() (tMembers string, err error) {

}*/

func (t Team) GetTeamTasks() (teamTasks string, err error) {
	if TeamTasks.Size() != 0 {
		existingWorkableTasks, exist := TeamTasks.Get(t.Id)
		if !exist {
			return "", ErrTeamTasksNotFound
		}

		// Perform a type assertion to convert interface{} to []*WorkableTask.
		tasksPtrs, ok := existingWorkableTasks.([]*WorkableTask)
		if !ok {
			return "", ErrTeamTasksIncorrectType
		}

		// Convert []*WorkableTask to []Task
		tasks := make([]zentasktic.Task, len(tasksPtrs))
		for i, wt := range tasksPtrs {
			tasks[i] = wt.Task 
		}

		// Check if there are actually any tasks in the slice.
		if len(tasks) == 0 {
			return "", ErrTeamTasksNotFound
		}

		// Create a TasksObject and marshal into JSON
		tasksObject := zentasktic.TasksObject{Tasks: tasks}
		marshaledTasks, err := tasksObject.MarshalJSON()
		if err != nil {
			return "", err 
		}

		// Return the JSON string and nil error on success.
		return string(marshaledTasks), nil
	}

	return "", ErrTeamTasksNotFound
}

func (t Team) GetTeamProjects() (teamProjects string, err error) {
	if TeamProjects.Size() != 0 {
		existingWorkableProjects, exist := TeamProjects.Get(t.Id)
		if !exist {
			return "", ErrTeamProjectsNotFound
		}

		// Perform a type assertion to convert interface{} to []*WorkableProject.
		projectPtrs, ok := existingWorkableProjects.([]*WorkableProject)
		if !ok {
			return "", ErrTeamProjectsIncorrectType
		}

		// Convert []*WorkableProject to []Project
		projects := make([]zentasktic.Project, len(projectPtrs))
		for i, wp := range projectPtrs {
			projects[i] = wp.Project 
		}

		// Check if there are actually any projects in the slice.
		if len(projects) == 0 {
			return "", ErrTeamProjectsNotFound
		}

		// Create a ProjectsObject and marshal into JSON
		projectsObject := zentasktic.ProjectsObject{Projects: projects}
		marshaledProjectss, err := projectsObject.MarshalJSON()
		if err != nil {
			return "", err 
		}

		// Return the JSON string and nil error on success.
		return string(marshaledProjectss), nil
	}

	return "", ErrTeamProjectsNotFound
}