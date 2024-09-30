package zentasktic_project

import (
	"errors"
	"gno.land/p/demo/zentasktic"
	"gno.land/p/demo/zteams"
	"std"
)

// GetTeamById retrieves a team by ID using TeamManager
func GetTeamById(teamId string) (*zteams.Team, error) {
	// Convert the teamId string to a std.Address format used by TeamManager
	teamAddress := std.Address(teamId)
	
	// Use TeamManager to get the team by its address
	team, err := TeamManager.GetTeam(teamAddress)
	if err != nil {
		return nil, errors.New("team ID not found")
	}
	return team, nil
}

// GetAllTeams retrieves all teams and returns them as a JSON string using TeamWrapper and TeamManager
func GetAllTeams() (string) {
	teams := make([]*TeamWrapper, 0)

	// Iterate over all teams managed by TeamManager
	TeamManager.Teams.Iterate("", "", func(key string, value interface{}) bool {
		team := value.(*zteams.Team)

		// Wrap the team in TeamWrapper
		teamWrapper := &TeamWrapper{Team: team}
		teams = append(teams, teamWrapper)

		return false // Continue iteration
	})

	// Create a TeamsObject to marshal the list of teams into JSON
	teamsObject := &TeamsObject{Teams: teams}
	marshalledTeams, err := teamsObject.MarshalJSON()
	if err != nil {
		return ""
	}

	return string(marshalledTeams)
}



// GetTeamTasks retrieves all tasks associated with a team using TeamWrapper
func (tw *TeamWrapper) GetTeamTasks() (string, error) {
    // Retrieve tasks associated with the team's address from TeamTasks
    tasks, exist := TeamTasks.Get(tw.Team.Address.String())
    if !exist {
        return "", errors.New("team tasks not found")
    }

    // Create a TasksObject to hold the marshaled tasks
    tasksObject := zentasktic.TasksObject{Tasks: make([]zentasktic.Task, 0)}
    for _, task := range tasks.([]WorkableTask) {
        tasksObject.Tasks = append(tasksObject.Tasks, task.Task)
    }

    // Marshal the tasks into JSON
    marshalledTasks, err := tasksObject.MarshalJSON()
    if err != nil {
        return "", err
    }

    return string(marshalledTasks), nil
}


// GetTeamProjects retrieves all projects associated with a team using TeamWrapper
func (tw *TeamWrapper) GetTeamProjects() (string, error) {
    // Retrieve projects associated with the team's address from TeamProjects
    projects, exist := TeamProjects.Get(tw.Team.Address.String())
    if !exist {
        return "", errors.New("team projects not found")
    }

    // Create a ProjectsObject to hold the marshaled projects
    projectsObject := zentasktic.ProjectsObject{Projects: make([]zentasktic.Project, 0)}
    for _, project := range projects.([]WorkableProject) {
        projectsObject.Projects = append(projectsObject.Projects, project.Project)
    }

    // Marshal the projects into JSON
    marshalledProjects, err := projectsObject.MarshalJSON()
    if err != nil {
        return "", err
    }

    return string(marshalledProjects), nil
}


// GetTeamsWithAssignedTasks retrieves all teams with assigned tasks from TeamTasks using TeamWrapper
func GetTeamsWithAssignedTasks() (string) {
    teamsWithAssignedTasks := make([]TeamTasksObject, 0)

    TeamTasks.Iterate("", "", func(key string, value interface{}) bool {
        tasks, ok := value.([]WorkableTask)
        if !ok {
            return false // Continue iteration if the value is not of the expected type
        }

        // Cast WorkableTask slice to zentasktic.Task slice
        taskList := make([]zentasktic.Task, len(tasks))
        for i, task := range tasks {
            taskList[i] = task.Task
        }

        // Retrieve the team from TeamManager using the key
        team, err := TeamManager.GetTeam(std.Address(key))
        if err != nil {
            return false // Skip this team if there's an error retrieving it
        }

        // Wrap the team in TeamWrapper
        teamWrapper := &TeamWrapper{Team: team}

        teamTaskObject := TeamTasksObject{
            TeamId:    teamWrapper.Team.Address.String(), // Use the address as the team ID
            TeamTasks: taskList,
        }

        teamsWithAssignedTasks = append(teamsWithAssignedTasks, teamTaskObject)
        return false // Continue iteration
    })

    // Create a TeamsTasksObject for marshaling into JSON
    teamsTasksObject := TeamsTasksObject{TeamsTasks: teamsWithAssignedTasks}
    marshalledTeamsTasks, err := teamsTasksObject.MarshalJSON()
    if err != nil {
        return ""
    }

    return string(marshalledTeamsTasks)
}

