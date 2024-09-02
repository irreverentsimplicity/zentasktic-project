package zentasktic_project

import (
	"gno.land/p/demo/avl"
	"gno.land/p/demo/zentasktic"
)

type Team struct {
	Id      string   `json:"teamId"`
	Name    string   `json:"teamName"`
	Members []*Actor `json:"teamMembers"`
}

var (
	Teams        avl.Tree // t.id -> *Team
	Members      avl.Tree // t.id -> []*Actor
	TeamTasks    avl.Tree // t.id -> []*WorkableTask
	TeamProjects avl.Tree // t.id -> []*WorkableProject
)

// AddTeam adds a new team to the Teams AVL tree
func (t *Team) AddTeam() error {
	if _, exist := Teams.Get(t.Id); exist {
		return ErrTeamIdAlreadyExists
	}
	Teams.Set(t.Id, t)
	return nil
}

// RemoveTeam removes a team from the Teams AVL tree and cleans up associated data
func (t *Team) RemoveTeam() error {
	if _, exist := Teams.Get(t.Id); !exist {
		return ErrTeamIdNotFound
	}

	// Remove the team from Members
	Members.Remove(t.Id)

	// Remove the team's tasks
	TeamTasks.Remove(t.Id)

	// Remove the team's projects
	TeamProjects.Remove(t.Id)

	// Remove the team from ActorTeams for all actor IDs
	ActorTeams.Iterate("", "", func(actorId string, value interface{}) bool {
		if actorTeams, ok := value.([]*Team); ok {
			for i, team := range actorTeams {
				if team.Id == t.Id {
					updatedTeams := append(actorTeams[:i], actorTeams[i+1:]...)
					if len(updatedTeams) == 0 {
						ActorTeams.Remove(actorId)
					} else {
						ActorTeams.Set(actorId, updatedTeams)
					}
					break
				}
			}
		}
		return false
	})

	// Finally, remove the team itself
	if _, removed := Teams.Remove(t.Id); !removed {
		return ErrTeamNotRemoved
	}
	return nil
}

// EditTeam updates an existing team's details in the Teams AVL tree
func (t *Team) EditTeam() error {
	if _, exist := Teams.Get(t.Id); !exist {
		return ErrTeamIdNotFound
	}
	Teams.Set(t.Id, t)
	return nil
}

// AssignTeamToTask assigns a task to a team
func (t *Team) AssignTeamToTask(wt *WorkableTask) error {
	existingWorkableTasks, _ := TeamTasks.Get(t.Id)
	tasks := existingWorkableTasks.([]*WorkableTask)
	TeamTasks.Set(t.Id, append(tasks, wt))
	return nil
}

// UnassignTeamFromTask unassigns a task from a team
func (t *Team) UnassignTeamFromTask(wt *WorkableTask) error {
	existingTeamTasks, exist := TeamTasks.Get(t.Id)
	if !exist {
		return ErrTeamTasksNotFound
	}

	tasks := existingTeamTasks.([]*WorkableTask)
	for i, task := range tasks {
		if task.Id == wt.Id {
			updatedTasks := append(tasks[:i], tasks[i+1:]...)
			TeamTasks.Set(t.Id, updatedTasks)
			return nil
		}
	}
	return ErrTeamTasksNotFound
}

// AssignTeamToProject assigns a project to a team
func (t *Team) AssignTeamToProject(wp *WorkableProject) error {
	existingWorkableProjects, _ := TeamProjects.Get(t.Id)
	projects := existingWorkableProjects.([]*WorkableProject)
	TeamProjects.Set(t.Id, append(projects, wp))
	return nil
}

// UnassignTeamFromProject unassigns a project from a team
func (t *Team) UnassignTeamFromProject(wp *WorkableProject) error {
	existingTeamProjects, exist := TeamProjects.Get(t.Id)
	if !exist {
		return ErrTeamProjectsNotFound
	}

	projects := existingTeamProjects.([]*WorkableProject)
	for i, project := range projects {
		if project.Id == wp.Id {
			updatedProjects := append(projects[:i], projects[i+1:]...)
			TeamProjects.Set(t.Id, updatedProjects)
			return nil
		}
	}
	return ErrTeamProjectsNotFound
}

// GetTeamById retrieves a team by ID
func GetTeamById(teamId string) (*Team, error) {
	team, exist := Teams.Get(teamId)
	if !exist {
		return nil, ErrTeamIdNotFound
	}
	return team.(*Team), nil
}

// GetAllTeams retrieves all teams and returns them as a JSON string
func GetAllTeams() (string) {
	var allTeams []*Team

	Teams.Iterate("", "", func(key string, value interface{}) bool {
		if team, ok := value.(*Team); ok {
			allTeams = append(allTeams, team)
		}
		return false
	})

	teamsObject := &TeamsObject{Teams: allTeams}
	marshalledTeams, err := teamsObject.MarshalJSON()
	if err != nil {
		return ""
	}
	return string(marshalledTeams)
}

// GetTeamTasks retrieves all tasks associated with a team
func (t *Team) GetTeamTasks() (string, error) {
	existingWorkableTasks, exist := TeamTasks.Get(t.Id)
	if !exist {
		return "", ErrTeamTasksNotFound
	}

	tasksPtrs := existingWorkableTasks.([]*WorkableTask)
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

// GetTeamProjects retrieves all projects associated with a team
func (t *Team) GetTeamProjects() (string, error) {
	existingWorkableProjects, exist := TeamProjects.Get(t.Id)
	if !exist {
		return "", ErrTeamProjectsNotFound
	}

	projectPtrs := existingWorkableProjects.([]*WorkableProject)
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
