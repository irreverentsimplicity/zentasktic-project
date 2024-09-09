package zentasktic_project

import (
	"errors"
	"gno.land/p/demo/zentasktic"
)

// AddTeam adds a new team to the Teams tree
func (t *Team) AddTeam() error {
	if _, terr := GetTeamById(t.Id); terr == nil {
		// terr == nil means we found a team
		return errors.New("team ID already exists")
	}
	Teams.Set(t.Id, t)
	return nil
}

// RemoveTeam removes a team from the Teams tree and cleans up associated data
func (t *Team) RemoveTeam() error {
	// Check if the team exists
	team, terr := GetTeamById(t.Id)
	if terr != nil {
		return errors.New("team ID not found")
	}

	// Remove the team from the Teams tree
	Teams.Remove(team.Id)
	// Remove the team's tasks and projects
	TeamTasks.Remove(team.Id)
	TeamProjects.Remove(team.Id)

	return nil
}


// EditTeam updates an existing team's details in the Teams tree
func (t *Team) EditTeam() error {
	_, terr := GetTeamById(t.Id)
	if terr != nil {
		return errors.New("team ID not found")
	}
	Teams.Set(t.Id, t)
	return nil
}

// AssignTeamToTask assigns a task to a team
func (t *Team) AssignTeamToTask(wt WorkableTask) error {
	// Add the task to the team's task list
	tasks, _ := TeamTasks.Get(t.Id)
	var updatedTasks []WorkableTask
	if tasks != nil {
		updatedTasks = tasks.([]WorkableTask)
	}
	for _, task := range updatedTasks {
		if task.Id == wt.Id {
			return nil // Task already assigned to team
		}
	}
	updatedTasks = append(updatedTasks, wt)
	TeamTasks.Set(t.Id, updatedTasks)
	return nil
}

// UnassignTeamFromTask unassigns a task from a team
func (t *Team) UnassignTeamFromTask(wt WorkableTask) error {
	tasks, exist := TeamTasks.Get(t.Id)
	if !exist {
		return errors.New("team task not found")
	}

	updatedTasks := tasks.([]WorkableTask)
	for i, task := range updatedTasks {
		if task.Id == wt.Id {
			updatedTasks = append(updatedTasks[:i], updatedTasks[i+1:]...)
			if len(updatedTasks) == 0 {
				TeamTasks.Remove(t.Id)
			} else {
				TeamTasks.Set(t.Id, updatedTasks)
			}
			return nil
		}
	}
	return errors.New("team task not found")
}

// AssignTeamToProject assigns a project to a team
func (t *Team) AssignTeamToProject(wp *WorkableProject) error {
	// Add the project to the team's project list
	projects, _ := TeamProjects.Get(t.Id)
	var updatedProjects []*WorkableProject
	if projects != nil {
		updatedProjects = projects.([]*WorkableProject)
	}
	for _, project := range updatedProjects {
		if project.Id == wp.Id {
			return nil // Project already assigned to team
		}
	}
	updatedProjects = append(updatedProjects, wp)
	TeamProjects.Set(t.Id, updatedProjects)
	return nil
}

// UnassignTeamFromProject unassigns a project from a team
func (t *Team) UnassignTeamFromProject(wp *WorkableProject) error {
	projects, exist := TeamProjects.Get(t.Id)
	if !exist {
		return errors.New("team project not found")
	}

	updatedProjects := projects.([]*WorkableProject)
	for i, project := range updatedProjects {
		if project.Id == wp.Id {
			updatedProjects = append(updatedProjects[:i], updatedProjects[i+1:]...)
			if len(updatedProjects) == 0 {
				TeamProjects.Remove(t.Id)
			} else {
				TeamProjects.Set(t.Id, updatedProjects)
			}
			return nil
		}
	}
	return errors.New("team project not found")
}

// GetTeamById retrieves a team by ID
func GetTeamById(teamId string) (*Team, error) {
	team, exist := Teams.Get(teamId)
	if exist {
		return team.(*Team), nil
	}
	return nil, errors.New("team ID not found")
}

// GetAllTeams retrieves all teams and returns them as a JSON string
func GetAllTeams() string {
	teams := make([]*Team, 0)
	Teams.Iterate("", "", func(key string, value interface{}) bool {
		teams = append(teams, value.(*Team))
		return false // Continue iteration
	})

	teamsObject := &TeamsObject{Teams: teams}
	marshalledTeams, err := teamsObject.MarshalJSON()
	if err != nil {
		return ""
	}
	return string(marshalledTeams)
}


// GetTeamTasks retrieves all tasks associated with a team
func (t *Team) GetTeamTasks() (string, error) {
	tasks, exist := TeamTasks.Get(t.Id)
	if !exist {
		return "", errors.New("team tasks not found")
	}

	tasksObject := zentasktic.TasksObject{Tasks: make([]zentasktic.Task, 0)}
	for _, task := range tasks.([]WorkableTask) {
		tasksObject.Tasks = append(tasksObject.Tasks, task.Task)
	}

	marshalledTasks, err := tasksObject.MarshalJSON()
	if err != nil {
		return "", err
	}

	return string(marshalledTasks), nil
}

// GetTeamProjects retrieves all projects associated with a team
func (t *Team) GetTeamProjects() (string, error) {
	projects, exist := TeamProjects.Get(t.Id)
	if !exist {
		return "", errors.New("team projects not found")
	}

	projectsObject := zentasktic.ProjectsObject{Projects: make([]zentasktic.Project, 0)}
	for _, project := range projects.([]WorkableProject) {
		projectsObject.Projects = append(projectsObject.Projects, project.Project)
	}

	marshalledProjects, err := projectsObject.MarshalJSON()
	if err != nil {
		return "", err
	}

	return string(marshalledProjects), nil
}

// GetTeamsWithAssignedTasks retrieves all teams with assigned tasks from TeamTasks
func GetTeamsWithAssignedTasks() (string) {
    teamsWithAssignedTasks := make([]TeamTasksObject, 0)
    
    TeamTasks.Iterate("", "", func(key string, value interface{}) bool {
        tasks, ok := value.([]WorkableTask)
        if !ok {
            return false // Continue iteration if the value is not of the expected type
        }

        // Cast []*WorkableTask to []zentasktic.Task
        taskList := make([]zentasktic.Task, len(tasks))
        for i, task := range tasks {
            taskList[i] = task.Task
        }

        teamTaskObject := TeamTasksObject{
            TeamId:    key,
            TeamTasks: taskList,
        }
        teamsWithAssignedTasks = append(teamsWithAssignedTasks, teamTaskObject)
        return false // Continue iteration
    })

    teamsTasksObject := TeamsTasksObject{TeamsTasks: teamsWithAssignedTasks}
    marshalledTeamsTasks, err := teamsTasksObject.MarshalJSON()
    if err != nil {
        return ""
    }
    return string(marshalledTeamsTasks)
}
