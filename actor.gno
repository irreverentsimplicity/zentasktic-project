package zentasktic_project

import (
	"errors"
	"gno.land/p/demo/zentasktic"
)

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
	_, err := GetActorById(a.Id)
	//  if err != nil, actor was not found
	if err != nil {
		return errors.New("actor ID not found")
	}

	// Remove actor from Actors tree
	Actors.Remove(a.Id)

	// Remove actor from any teams they belong to
	Teams.Iterate("", "", func(key string, value interface{}) bool {
		team := value.(*Team)
		for i, member := range team.Members {
			if member.Id == a.Id {
				team.Members = append(team.Members[:i], team.Members[i+1:]...)
				break
			}
		}
		return false // Continue iteration
	})

	// Remove actor's tasks and projects
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

func (a *Actor) AddActorToTeam(t *Team) error {
    actor, err := GetActorById(a.Id)
    if err != nil {
        return errors.New("actor ID not found")
    }

    // Check if the team exists
    existingTeam, terr := GetTeamById(t.Id)
    if terr != nil {
        return errors.New("team ID not found")
    }

    // Check if the actor is already a member of the team
    for _, member := range existingTeam.Members {
        if member.Id == a.Id {
            return nil // Actor is already a member of the team
        }
    }

    // Add the actor to the team
    existingTeam.Members = append(existingTeam.Members, actor)
    Teams.Set(existingTeam.Id, existingTeam) // Update the team in the tree
    return nil
}

func (a *Actor) RemoveActorFromTeam(t *Team) error {
    // Check if the team exists
    existingTeam, terr := GetTeamById(t.Id)
    if terr != nil {
        return errors.New("team ID not found")
    }

    // Find and remove the actor from the team's members list
    for i, member := range existingTeam.Members {
        if member.Id == a.Id {
            existingTeam.Members = append(existingTeam.Members[:i], existingTeam.Members[i+1:]...)
            Teams.Set(existingTeam.Id, existingTeam) // Update the team in the tree
            return nil
        }
    }

    return errors.New("actor not found in team")
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
	if exist {
		return actor.(*Actor), nil
	}
	return nil, errors.New("actor ID not found")
}

// GetAllActors retrieves all actors and returns them as a JSON string
func GetAllActors() string {
	actors := make([]*Actor, 0)
	Actors.Iterate("", "", func(key string, value interface{}) bool {
		actors = append(actors, value.(*Actor))
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
	var actorTeams []*Team

	Teams.Iterate("", "", func(key string, value interface{}) bool {
		team := value.(*Team)
		for _, member := range team.Members {
			if member.Id == a.Id {
				actorTeams = append(actorTeams, team)
				break
			}
		}
		return false // Continue iteration
	})

	if len(actorTeams) == 0 {
		return "", errors.New("actor teams not found")
	}

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
