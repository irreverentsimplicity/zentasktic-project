package zentasktic_project

import (
	"errors"
	"gno.land/p/demo/zentasktic"
	"gno.land/p/demo/users"
	"gno.land/p/demo/zteams"
)

// Converts an Actor to a zteams User for compatibility with TeamManager
func (a *Actor) ToUser() users.User {
	return users.User{
		Name:    a.Name,
		Address: a.Address,
	}
}

// Converts a zteams User to an Actor for use within zentasktic_project
func FromUser(u users.User) *Actor {
	return &Actor{
		Name:    u.Name,
		Address: u.Address,
	}
}

// AddActor adds a new actor to the Actors tree
func (a *Actor) AddActor() error {
	if _, err := GetActorById(a.Id); err == nil {
		// actor found, err is nil
		return errors.New("actor ID already exists")
	}
	Actors.Set(a.Id, a)
	return nil
}

// RemoveActor removes an actor from the Actors tree and cleans up associated data
func (a *Actor) RemoveActor() error {
	// Check if the actor exists in the Actors tree
	_, err := GetActorById(a.Id)
	if err != nil {
		return errors.New("actor ID not found")
	}

	// Remove the actor from the Actors tree
	Actors.Remove(a.Id)

	// Use TeamManager to remove the actor from any teams they belong to
	// Get all teams and check if the actor is a member, admin, or owner, and remove accordingly
	TeamManager.Teams.Iterate("", "", func(key string, value interface{}) bool {
		team := value.(*zteams.Team)
		
		// Remove the actor from the team if they are a member
		_ = TeamManager.RemoveUserFromTeam(team.Address, a.Address, team.Owner)
		return false // Continue iteration
	})

	// Remove the actor's tasks and projects
	ActorTasks.Remove(a.Id)
	ActorProjects.Remove(a.Id)

	return nil
}


// EditActor updates an existing actor's details in the Actors tree
func (a *Actor) EditActor() error {
	_, err := GetActorById(a.Id)
	if err != nil {
		return errors.New("actor ID not found")
	}
	Actors.Set(a.Id, a)
	return nil
}

// AssignActorToTask assigns a task to an actor
func (a *Actor) AssignActorToTask(wt *WorkableTask) error {
	// Add the task to the actor's task list
	tasks, _ := ActorTasks.Get(a.Id)
	var updatedTasks []*WorkableTask
	if tasks != nil {
		updatedTasks = tasks.([]*WorkableTask)
	}
	for _, task := range updatedTasks {
		if task.Id == wt.Id {
			return nil // Task already assigned to actor
		}
	}
	updatedTasks = append(updatedTasks, wt)
	ActorTasks.Set(a.Id, updatedTasks)
	return nil
}

// UnassignActorFromTask unassigns a task from an actor
func (a *Actor) UnassignActorFromTask(wt *WorkableTask) error {
	tasks, exist := ActorTasks.Get(a.Id)
	if !exist {
		return errors.New("actor task not found")
	}

	updatedTasks := tasks.([]*WorkableTask)
	for i, task := range updatedTasks {
		if task.Id == wt.Id {
			updatedTasks = append(updatedTasks[:i], updatedTasks[i+1:]...)
			if len(updatedTasks) == 0 {
				ActorTasks.Remove(a.Id)
			} else {
				ActorTasks.Set(a.Id, updatedTasks)
			}
			return nil
		}
	}
	return errors.New("actor task not found")
}

// AssignActorToProject assigns a project to an actor
func (a *Actor) AssignActorToProject(wp *WorkableProject) error {
	// Add the project to the actor's project list
	projects, _ := ActorProjects.Get(a.Id)
	var updatedProjects []*WorkableProject
	if projects != nil {
		updatedProjects = projects.([]*WorkableProject)
	}
	for _, project := range updatedProjects {
		if project.Id == wp.Id {
			return nil // Project already assigned to actor
		}
	}
	updatedProjects = append(updatedProjects, wp)
	ActorProjects.Set(a.Id, updatedProjects)
	return nil
}

// UnassignActorFromProject unassigns a project from an actor
func (a *Actor) UnassignActorFromProject(wp *WorkableProject) error {
	projects, exist := ActorProjects.Get(a.Id)
	if !exist {
		return errors.New("actor project not found")
	}

	updatedProjects := projects.([]*WorkableProject)
	for i, project := range updatedProjects {
		if project.Id == wp.Id {
			updatedProjects = append(updatedProjects[:i], updatedProjects[i+1:]...)
			if len(updatedProjects) == 0 {
				ActorProjects.Remove(a.Id)
			} else {
				ActorProjects.Set(a.Id, updatedProjects)
			}
			return nil
		}
	}
	return errors.New("actor project not found")
}

// GetActorById retrieves an actor by ID
func GetActorById(actorId string) (*Actor, error) {
	actor, exist := Actors.Get(actorId)
	if !exist {
		return nil, errors.New("actor ID not found")
	}

	a, ok := actor.(*Actor)
	if !ok {
		return nil, errors.New("type assertion to *Actor failed")
	}

	return a, nil
}


// GetAllActors retrieves all actors and returns them as a JSON string
func GetAllActors() string {
	actors := make([]*Actor, 0)
	Actors.Iterate("", "", func(key string, value interface{}) bool {
		if a, ok := value.(*Actor); ok {
			actors = append(actors, a)
		} 
		return false // Continue iteration
	})

	actorsObject := &ActorsObject{Actors: actors}
	marshalledActors, err := actorsObject.MarshalJSON()
	if err != nil {
		return ""
	}
	return string(marshalledActors)
}

// GetActorTeams retrieves all teams associated with an actor
func (a *Actor) GetActorTeams() (string, error) {
	var actorTeams []*zteams.Team

	// Iterate through all teams managed by TeamManager
	TeamManager.Teams.Iterate("", "", func(key string, value interface{}) bool {
		team := value.(*zteams.Team)

		// Get all members of the team
		members, err := TeamManager.GetAllUsersInTeam(team.Address)
		if err != nil {
			return false // Skip if there was an error retrieving members
		}

		// Check if the actor is a member of this team
		for _, member := range members {
			if member.Address == a.Address {
				actorTeams = append(actorTeams, team)
				break
			}
		}

		return false // Continue iteration
	})

	if len(actorTeams) == 0 {
		return "", errors.New("actor teams not found")
	}

	// Convert zteams.Team objects to the TeamsObject format for JSON marshalling
	teamsObject := &TeamsObject{Teams: actorTeams}
	marshalledTeams, err := teamsObject.MarshalJSON()
	if err != nil {
		return "", err
	}

	return string(marshalledTeams), nil
}

// GetActorTasks retrieves all tasks associated with an actor
func (a *Actor) GetActorTasks() (string, error) {
    // Retrieve tasks associated with the actor's ID
    tasks, exist := ActorTasks.Get(a.Id)
    if !exist {
        return "", errors.New("actor tasks not found")
    }

    // Create a TasksObject to hold the list of tasks
    tasksObject := zentasktic.TasksObject{Tasks: make([]zentasktic.Task, 0)}
    
    // Iterate through the slice of WorkableTask and append the Task to tasksObject.Tasks
    for _, task := range tasks.([]*WorkableTask) {
        tasksObject.Tasks = append(tasksObject.Tasks, task.Task)
    }

    // Marshal the tasks into JSON format
    marshalledTasks, err := tasksObject.MarshalJSON()
    if err != nil {
        return "", err
    }

    return string(marshalledTasks), nil
}

// GetActorProjects retrieves all projects associated with an actor
func (a *Actor) GetActorProjects() (string, error) {
	projects, exist := ActorProjects.Get(a.Id)
	if !exist {
		return "", errors.New("actor projects not found")
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
