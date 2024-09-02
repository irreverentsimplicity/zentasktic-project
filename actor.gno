package zentasktic_project

import (
	"std"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/zentasktic"
)

type Actor struct {
	Id      string      `json:"actorId"`
	Name    string      `json:"actorName"`
	Address std.Address `json:"actorAddress"`
}

var (
	Actors        avl.Tree // a.id -> *Actor
	ActorTeams    avl.Tree // a.id -> []*Team
	ActorTasks    avl.Tree // a.id -> []*WorkableTask
	ActorProjects avl.Tree // a.id -> []*WorkableProject
)

// AddActor adds a new actor to the Actors tree
func (a *Actor) AddActor() error {
	if _, exist := Actors.Get(a.Id); exist {
		return ErrActorIdAlreadyExists
	}
	Actors.Set(a.Id, a)
	return nil
}

// RemoveActor removes an actor from the Actors tree and cleans up associated data
func (a *Actor) RemoveActor() error {
	if _, exist := Actors.Get(a.Id); !exist {
		return ErrActorIdNotFound
	}

	// Remove actor from any teams they belong to
	if existingActorTeams, exist := ActorTeams.Get(a.Id); exist {
		for _, team := range existingActorTeams.([]*Team) {
			teamMembers, membersExist := Members.Get(team.Id)
			if membersExist {
				// Remove actor from the team's member list
				members := teamMembers.([]*Actor)
				for i, member := range members {
					if member.Id == a.Id {
						members = append(members[:i], members[i+1:]...)
						Members.Set(team.Id, members)
						break
					}
				}
			}
		}
		ActorTeams.Remove(a.Id)
	}

	// Remove actor's tasks
	ActorTasks.Remove(a.Id)

	// Remove actor's projects
	ActorProjects.Remove(a.Id)

	// Finally, remove the actor
	if _, removed := Actors.Remove(a.Id); !removed {
		return ErrActorNotRemoved
	}
	return nil
}

// EditActor updates an existing actor's details in the Actors tree
func (a *Actor) EditActor() error {
	if _, exist := Actors.Get(a.Id); !exist {
		return ErrActorIdNotFound
	}
	Actors.Set(a.Id, a)
	return nil
}

func (a *Actor) AddActorToTeam(t *Team) error {
	if _, exist := Actors.Get(a.Id); !exist {
		return ErrActorIdNotFound
	}

	// Update ActorTeams
	existingActorTeams, _ := ActorTeams.Get(a.Id)
	var actorTeams []*Team
	if existingActorTeams != nil {
		actorTeams = existingActorTeams.([]*Team)
	} else {
		actorTeams = []*Team{}
	}
	
	// Check if the team already exists in the actor's list
	for _, team := range actorTeams {
		if team.Id == t.Id {
			return nil // Team already exists
		}
	}

	// Add the team to the actor's list
	actorTeams = append(actorTeams, t)
	ActorTeams.Set(a.Id, actorTeams)

	// Update Members
	existingMembers, _ := Members.Get(t.Id)
	var members []*Actor
	if existingMembers != nil {
		members = existingMembers.([]*Actor)
	} else {
		members = []*Actor{}
	}
	members = append(members, a)
	Members.Set(t.Id, members)

	// Update the Members field in the team directly
	t.Members = members

	return nil
}


// RemoveActorFromTeam removes an actor from a team
func (a *Actor) RemoveActorFromTeam(t *Team) error {
	existingActorTeams, exist := ActorTeams.Get(a.Id)
	if !exist {
		return ErrActorTeamsNotFound
	}

	teams := existingActorTeams.([]*Team)
	for i, team := range teams {
		if team.Id == t.Id {
			// Remove team from actor's team list
			updatedTeams := append(teams[:i], teams[i+1:]...)
			ActorTeams.Set(a.Id, updatedTeams)
			break
		}
	}

	// Remove actor from team's member list
	existingMembers, _ := Members.Get(t.Id)
	members := existingMembers.([]*Actor)
	for i, member := range members {
		if member.Id == a.Id {
			updatedMembers := append(members[:i], members[i+1:]...)
			Members.Set(t.Id, updatedMembers)

			// Directly update the team's Members field
			t.Members = updatedMembers
			break
		}
	}

	return nil
}

// AssignActorToTask assigns a task to an actor
func (a *Actor) AssignActorToTask(wt *WorkableTask) error {
	existingTasks, _ := ActorTasks.Get(a.Id)
	tasks := existingTasks.([]*WorkableTask)
	ActorTasks.Set(a.Id, append(tasks, wt))
	return nil
}

// UnassignActorFromTask unassigns a task from an actor
func (a *Actor) UnassignActorFromTask(wt *WorkableTask) error {
	existingTasks, exist := ActorTasks.Get(a.Id)
	if !exist {
		return ErrActorTasksNotFound
	}

	tasks := existingTasks.([]*WorkableTask)
	for i, task := range tasks {
		if task.Id == wt.Id {
			updatedTasks := append(tasks[:i], tasks[i+1:]...)
			ActorTasks.Set(a.Id, updatedTasks)
			return nil
		}
	}
	return ErrActorTasksNotFound
}

// AssignActorToProject assigns a project to an actor
func (a *Actor) AssignActorToProject(wp *WorkableProject) error {
	existingProjects, _ := ActorProjects.Get(a.Id)
	projects := existingProjects.([]*WorkableProject)
	ActorProjects.Set(a.Id, append(projects, wp))
	return nil
}

// UnassignActorFromProject unassigns a project from an actor
func (a *Actor) UnassignActorFromProject(wp *WorkableProject) error {
	existingProjects, exist := ActorProjects.Get(a.Id)
	if !exist {
		return ErrActorProjectsNotFound
	}

	projects := existingProjects.([]*WorkableProject)
	for i, project := range projects {
		if project.Id == wp.Id {
			updatedProjects := append(projects[:i], projects[i+1:]...)
			ActorProjects.Set(a.Id, updatedProjects)
			return nil
		}
	}
	return ErrActorProjectsNotFound
}

// GetActorById retrieves an actor by ID
func GetActorById(actorId string) (*Actor, error) {
	actor, exist := Actors.Get(actorId)
	if !exist {
		return nil, ErrActorIdNotFound
	}
	return actor.(*Actor), nil
}

// GetAllActors retrieves all actors and returns them as a JSON string
func GetAllActors() (string) {
	var allActors []Actor

	// Collect all Actor objects
	Actors.Iterate("", "", func(key string, value interface{}) bool {
		if actor, ok := value.(*Actor); ok {
			allActors = append(allActors, *actor) // Dereference pointer to store value
		}
		return false
	})

	actorsObject := &ActorsObject{Actors: allActors}
	marshalledActors, err := actorsObject.MarshalJSON()
	if err != nil {
		return ""
	}
	return string(marshalledActors)
}

// GetActorTeams retrieves all teams associated with an actor
func (a *Actor) GetActorTeams() (string, error) {
	existingActorTeams, exist := ActorTeams.Get(a.Id)
	if !exist {
		return "", ErrActorTeamsNotFound
	}

	teams := existingActorTeams.([]*Team)
	if len(teams) == 0 {
		return "", ErrActorTeamsNotFound
	}

	teamsObject := &TeamsObject{Teams: teams}
	marshalledTeams, err := teamsObject.MarshalJSON()
	if err != nil {
		return "", err
	}

	return string(marshalledTeams), nil
}

// GetActorTasks retrieves all tasks associated with an actor
func (a *Actor) GetActorTasks() (string, error) {
	existingWorkableTasks, exist := ActorTasks.Get(a.Id)
	if !exist {
		return "", ErrActorTasksNotFound
	}

	tasksPtrs := existingWorkableTasks.([]*WorkableTask)
	if len(tasksPtrs) == 0 {
		return "", ErrActorTasksNotFound
	}

	tasks := make([]zentasktic.Task, len(tasksPtrs))
	for i, wt := range tasksPtrs {
		tasks[i] = wt.Task
	}

	tasksObject := zentasktic.TasksObject{Tasks: tasks}
	marshaledTasks, err := tasksObject.MarshalJSON()
	if err != nil {
		return "", err
	}

	return string(marshaledTasks), nil
}

// GetActorProjects retrieves all projects associated with an actor
func (a *Actor) GetActorProjects() (string, error) {
	existingWorkableProjects, exist := ActorProjects.Get(a.Id)
	if !exist {
		return "", ErrActorProjectsNotFound
	}

	projectPtrs := existingWorkableProjects.([]*WorkableProject)
	if len(projectPtrs) == 0 {
		return "", ErrActorProjectsNotFound
	}

	projects := make([]zentasktic.Project, len(projectPtrs))
	for i, wp := range projectPtrs {
		projects[i] = wp.Project
	}

	projectsObject := zentasktic.ProjectsObject{Projects: projects}
	marshaledProjects, err := projectsObject.MarshalJSON()
	if err != nil {
		return "", err
	}

	return string(marshaledProjects), nil
}
