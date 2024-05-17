package zentasktic_project

import (
	"strconv"
	"errors"
	"std"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/zentasktic"
)

type Actor struct {
	Id 		    	string `json:"actorId"`
	Name 		    string `json:"actorName"`
	Address			std.Address	`json:"actorAddress"`
    // github handle?
}

var (
	Actors avl.Tree // a.id -> a
	ActorTeams avl.Tree // a.id -> []*Teams
	ActorTasks avl.Tree // a.id -> []*WorkableTask
	ActorProjects avl.Tree // a.id -> []*WorkableProject
)

func (a Actor) AddActor() (err error) { 
	// implementation
	
	if Actors.Size() != 0 {
		existingActor, exist := Actors.Get(a.Id)
		if exist {
			return ErrActorIdAlreadyExists
		}
	}
	Actors.Set(a.Id, a)
	return nil

}

func (a Actor) RemoveActor() (err error) {
	// implementation
	existingActor := Actor{}
	if Actors.Size() != 0 {
		existingActor, exist := Actors.Get(a.Id)
		if !exist {
			return ErrActorIdNotFound
		}
	}
	
	// if actor is part of the team, remove it from there too
	if ActorTeams.Size() != 0 {
		existingActorTeams, exist := ActorTeams.Get(a.Id)
		if exist {
			_, removed := ActorTeams.Remove(a.Id)
			if !removed {
				return ErrActorTeamsNotRemoved
			}

			// iterate over Members and remove Actor from there too
			for i, team := range existingActorTeams.([]*Team) {
				teamMembers, membersExist := Members.Get(team.Id)
				if membersExist {
					var index int = -1
					for m, teamActor := range teamMembers.([]*Actor) {
						if a.Id == teamActor.Id {
							index = m
							break
						}
					}
					// If the actor was found, we remove it from the slice.
					if index != -1 {
						teamMembers = append(teamMembers.([]*Actor)[:index], teamMembers.([]*Actor)[index+1:]...)
					} else {
						// Actor not found in the Members tree
						return ErrActorIdNotFound 
					}
					Members.Set(team.Id, teamMembers)
				}
			}
		}
	}

	// if actor has tasks assigned, unassign from them
	if ActorTasks.Size() != 0 {
		existingActorTasks, exist := ActorTasks.Get(a.Id)
		if exist {
			_, removed := ActorTasks.Remove(a.Id)
			if !removed {
				return ErrActorTasksNotRemoved
			}
		}
	}

	// if actor has projects assigned, unassign from them
	if ActorProjects.Size() != 0 {
		existingActorProjects, exist := ActorProjects.Get(a.Id)
		if exist {
			_, removed := ActorProjects.Remove(a.Id)
			if !removed {
				return ErrActorProjectsNotRemoved
			}
		}
	}

	// remove actor
	_, removed := Actors.Remove(a.Id)
	if !removed {
		return ErrActorNotRemoved
	}
	return nil

}

func (a Actor) EditActor() (err error) {
	// implementation, get actor by Id and replace the object
	existingActor := Actor{}
	if Actors.Size() != 0 {
		existingActor, exist := Actors.Get(a.Id)
		if !exist {
			return ErrActorIdNotFound
		}
	}
	
	Actors.Set(a.Id, a)
	return nil
}

func (a Actor) AddActorToTeam(t Team) (err error) {
	// we cross reference actor membership in 2 objects: ActorTeams, and Members
	existingActor := Actor{}
	if Actors.Size() != 0 {
		existingActor, exist := Actors.Get(a.Id)
		if !exist {
			return ErrActorIdNotFound
		}
	}

	// Update ActorTeams
    var updatedTeams []*Team
    existingActorTeams, exist := ActorTeams.Get(a.Id)
    if exist {
        teams, ok := existingActorTeams.([]*Team)
        if !ok {
            return ErrActorTeamsNotFound
        }
        updatedTeams = append(teams, &t)
    } else {
        updatedTeams = []*Team{&t}
    }
    ActorTeams.Set(a.Id, updatedTeams)

    // Update Members
    var updatedMembers []*Actor
    existingMembers, exist := Members.Get(t.Id)
    if exist {
        members, ok := existingMembers.([]*Actor)
        if !ok {
            return ErrTeamMembersNotFound
        }
        updatedMembers = append(members, &a)
    } else {
        updatedMembers = []*Actor{&a}
    }
    Members.Set(t.Id, updatedMembers)

	// Update the Members field of the Team struct
	t.Members = updatedMembers

	// Update the Team in the ActorTeams map to reflect the added member
	for i, team := range updatedTeams {
		if team.Id == t.Id {
			updatedTeams[i] = &t
			break
		}
	}
	ActorTeams.Set(a.Id, updatedTeams)

    return nil

}

func (a Actor) RemoveActorFromTeam(t Team) (err error) {
	if ActorTeams.Size() != 0 {
		existingActorTeams, exist := ActorTeams.Get(a.Id)
		if exist {
			var tindex int = -1
			teams := existingActorTeams.([]*Team)
			for i, team := range teams {
				if t.Id == team.Id {
					tindex = i
					break
				}
			}

			if tindex != -1 {
				teams = append(teams[:tindex], teams[tindex+1:]...)
				ActorTeams.Set(a.Id, teams)
			} else {
				// Team ID not found in the actor's teams
				return ErrTeamIdNotFound
			}
		}
	}

	// Iterate over Members and remove Actor from there too
	if Members.Size() != 0 {
		teamMembers, membersExist := Members.Get(t.Id)
		if membersExist {
			members, ok := teamMembers.([]*Actor)
			if !ok {
				return ErrActorIdNotFound
			}

			var index int = -1
			for m, teamActor := range members {
				if a.Id == teamActor.Id {
					index = m
					break
				}
			}

			// If the actor was found, we remove it from the slice.
			if index != -1 {
				members = append(members[:index], members[index+1:]...)
				Members.Set(t.Id, members)

				// Update the Members field of the Team struct in ActorTeams
				existingActorTeams, _ := ActorTeams.Get(a.Id)
				teams, _ := existingActorTeams.([]*Team)
				for _, team := range teams {
					if team.Id == t.Id {
						team.Members = members
						break
					}
				}
				ActorTeams.Set(a.Id, teams)
			} else {
				return ErrActorIdNotFound
			}
		}
	}

	return nil
}

func (a Actor) AssignActorToTask(wt *WorkableTask) error {
    if ActorTasks.Size() != 0 {
        existingWorkableTasks, ok := ActorTasks.Get(a.Id)
        if !ok {
            existingWorkableTasks = []*WorkableTask{}
        }
        
        tasks, ok := existingWorkableTasks.([]*WorkableTask)
        if !ok {
            return ErrActorTasksNotFound
        }
        
        updatedTasks := append(tasks, wt)
        ActorTasks.Set(a.Id, updatedTasks)
    } else {
        ActorTasks.Set(a.Id, []*WorkableTask{wt})
    }
    return nil
}

func (a Actor) UnassignActorFromTask(wt *WorkableTask) error {
    if ActorTasks.Size() != 0 {
        existingActorTasks, exist := ActorTasks.Get(a.Id)
        if !exist {
            return ErrActorTasksNotFound
        }

        tasks, ok := existingActorTasks.([]*WorkableTask)
        if !ok {
            return ErrActorTasksNotFound
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
            ActorTasks.Set(a.Id, updatedTasks)
        } else {
            return ErrActorTasksNotFound
        }
    } else {
        return ErrActorTasksNotFound
    }
    return nil
}

func (a Actor) AssignActorToProject(wp *WorkableProject) (err error) {
	if ActorProjects.Size() != 0 {
        existingWorkableProjects, ok := ActorProjects.Get(a.Id)
        if !ok {
            existingWorkableProjects = []*WorkableProject{}
        }
        
        projects, ok := existingWorkableProjects.([]*WorkableProject)
        if !ok {
            return ErrActorProjectsNotFound
        }
        
        updatedProjects := append(projects, wp)
        ActorProjects.Set(a.Id, updatedProjects)
    } else {
        ActorProjects.Set(a.Id, []*WorkableProject{wp})
    }
    return nil
} 

func (a Actor) UnassignActorFromProject(wp *WorkableProject) error {
    if ActorProjects.Size() != 0 {
        existingActorProjects, exist := ActorProjects.Get(a.Id)
        if !exist {
            return ErrActorProjectsNotFound
        }

        projects, ok := existingActorProjects.([]*WorkableProject)
        if !ok {
            return ErrActorProjectsNotFound
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
            ActorProjects.Set(a.Id, updatedProjects)
        } else {
            return ErrActorProjectsNotFound
        }
    } else {
        return ErrActorProjectsNotFound
    }
    return nil
}


// getters

func GetActorById(actorId string) (a Actor, err error) {
	if Actors.Size() != 0 {
		actor, exist := Actors.Get(actorId)
		if exist {
			return actor.(Actor), nil
		} else {
			return nil, ErrActorIdNotFound
		}

	}
	return nil, ErrActorIdNotFound
}

func GetAllActors()(actors string, err error) {
	// implementation
	var allActors []Actor

	// Iterate over the Actors AVL tree to collect all Actor objects.
	Actors.Iterate("", "", func(key string, value interface{}) bool {
		if actor, ok := value.(Actor); ok {
			allActors = append(allActors, actor)
		}
		return false // Continue iteration until all nodes have been visited.
	})

	// Create a ActorsObject with all collected actors.
	actorsObject := &ActorsObject{
		Actors: allActors,
	}

	// Use the custom MarshalJSON method to marshal the actors into JSON.
	marshalledActors, merr := actorsObject.MarshalJSON()
	if merr != nil {
		return "", merr
	} 
	return string(marshalledActors), nil
}

func (a Actor) GetActorTeams() (aTeams string, err error) {
	var actorTeams []*Team

	existingActorTeams, exist := ActorTeams.Get(a.Id)
	if !exist {
        // No record in ActorTeams.
        return "", ErrActorTeamsNotFound
    }

    // Assert that the returned interface{} is of type []*Team
    teams, ok := existingActorTeams.([]*Team)
    if !ok {
        // Data was not of the expected type; handle the error appropriately.
        return "", ErrActorTeamsIncorrectType
    }
    actorTeams = teams

    // Check if there are any teams before marshalling
    if len(actorTeams) == 0 {
        return "", ErrActorTeamsNotFound
    }

    // Create a TeamsObject and marshal into JSON
    teamsObject := &TeamsObject{
        Teams: actorTeams,
    }
    marshalledTeams, err := teamsObject.MarshalJSON()
    if err != nil {
        return "", err
    }

    return string(marshalledTeams), nil
}

func (a Actor) GetActorTasks() (actorTasks string, err error) {
	if ActorTasks.Size() != 0 {
		existingWorkableTasks, exist := ActorTasks.Get(a.Id)
		if !exist {
			return "", ErrActorTasksNotFound
		}

		// Perform a type assertion to convert interface{} to []*WorkableTask.
		tasksPtrs, ok := existingWorkableTasks.([]*WorkableTask)
		if !ok {
			return "", ErrActorTasksIncorrectType
		}

		// Convert []*WorkableTask to []Task
		tasks := make([]zentasktic.Task, len(tasksPtrs))
		for i, wt := range tasksPtrs {
			tasks[i] = wt.Task 
		}

		// Check if there are actually any tasks in the slice.
		if len(tasks) == 0 {
			return "", ErrActorTasksNotFound
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

	return "", ErrActorTasksNotFound
}

func (a Actor) GetActorProjects() (actorProjects string, err error) {
	if ActorProjects.Size() != 0 {
		existingWorkableProjects, exist := ActorProjects.Get(a.Id)
		if !exist {
			return "", ErrActorProjectsNotFound
		}

		// Perform a type assertion to convert interface{} to []*WorkableProject.
		projectPtrs, ok := existingWorkableProjects.([]*WorkableProject)
		if !ok {
			return "", ErrActorProjectsIncorrectType
		}

		// Convert []*WorkableProject to []Project
		projects := make([]zentasktic.Project, len(projectPtrs))
		for i, wp := range projectPtrs {
			projects[i] = wp.Project 
		}

		// Check if there are actually any projects in the slice.
		if len(projects) == 0 {
			return "", ErrActorProjectsNotFound
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

	return "", ErrActorProjectsNotFound
}