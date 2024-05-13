package zentasktic_project

import (
	"strconv"
	"errors"

	"gno.land/p/demo/avl"
)

type Actor struct {
	Id 		    	string `json:"actorId"`
	Name 		    string `json:"actorName"`
	Address			std.Address	`json:"actorAddress"`
    // github handle?
}

var {
	Actors avl.Tree // a.id -> a
	ActorTeams avl.Tree // a.id -> []*Teams
	ActorTasks avl.Tree // a.id -> []*WorkableTask
	ActorProjects avl.Tree // a.id -> []*WorkableProject
}

func (a Actor) AddActor() (err errors) { 
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

func (a Actor) RemoveActor() (err errors) {
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

func (a Actor) EditActor() (err errors) {
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

func (a Actor) AddActorToTeam(t Team) (err errors) {
	// we cross reference actor membership in 2 objects: ActorTeams, and Members
	existingActor := Actor{}
	if Actors.Size() != 0 {
		existingActor, exist := Actors.Get(a.Id)
		if !exist {
			return ErrActorIdNotFound
		}
	}

	existingTeam := Team{}
	if Teams.Size() != 0 {
		existingTeam, exist := Teams.Get(t.Id)
		if !exist {
			return ErrTeamIdNotFound
		}
	}

	// ActorTeams
	existingActorTeams, texist := ActorTeams.Get(a.Id)
	if !texist {
		// If the actor teams tree has no teams yet, initialize the slice.
		existingActorTeams = []*Team{}
	} else {
		teams, ok := existingActorTeams.([]*Team)
		if !ok {
			return ErrActorTeamsNotFound
		}
		existingActorTeams = teams
	}
	
	updatedTeams := append(existingActorTeams.([]*Team), t)
	ActorTeams.Set(a.Id, updatedTeams)

	// Members
	existingMembers, mexist := Members.Get(t.Id)
	if !mexist {
		// If the members tree has no actors yet, initialize the slice.
		existingMembers = []*Actor{}
	} else {
		members, ok := existingMembers.([]*Actor)
		if !ok {
			return ErrTeamMembersNotFound
		}
		existingMembers = members
	}
	
	updatedMembers := append(existingMembers.([]*Actor), a)
	Members.Set(t.Id, updatedMembers)

}

func (a Actor) RemoveActorFromTeam(t Team) (err errors) {
	if ActorTeams.Size() != 0 {
		existingActorTeams, exist := ActorTeams.Get(a.Id)
		if exist {

			var tindex int = -1
			for i, team := range existingActorTeams.([]*Team) {
				if t.id == team.id {
					tindex = i
					break
				}
				if tindex != -1 {
					existingActorTeams = append(existingActorTeams.([]*Team)[:tindex], existingActorTeams.([]*Team)[tindex+1:]...)
				} else {
					// Actor not found in the Members tree
					return ErrTeamIdNotFound 
				}
				ActorTeams.Set(a.Id, existingActorTeams)
			}
		}
	}

	// iterate over Members and remove Actor from there too
	if Members.Size() != 0 {
		teamMembers, membersExist := Members.Get(t.Id)
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

	return nil
}

func (a Actor) AssignActorToTask(wt WorkableTask) (err errors) {
	if ActorTasks.Size() != 0 {
		existingWorkableTasks, ok := ActorTasks.Get(a.Id)
		if !ok {
			existingWorkableTasks = []*WorkableTask{}
		}
		else {
			tasks, ok := existingWorkableTasks([]*WorkableTask)
			if !ok {
				return ErrActorTasksNotFound
			}
			existingWorkableTasks = tasks
		}
		updatedTasks := append(existingWorkableTasks.([]*WorkableTask), wt)
		ActorTasks.Set(a.Id, updatedTasks)
	}
	return nil
} 

func (a Actor) UnassignActorFromTask(wt WorkableTask) (err errors) {
	if ActorTasks.Size() != 0 {
		existingActorTasks, exist := ActorTasks.Get(a.Id)
		if exist {

			var tindex int = -1
			for i, task := range existingActorTasks.([]*WorkableTask) {
				if wt.id == task.id {
					tindex = i
					break
				}
				if tindex != -1 {
					existingActorTasks = append(existingActorTasks.([]*WorkableTask)[:tindex], existingActorTasks.([]*WorkableTask)[tindex+1:]...)
				} else {
					// Actor tasks not found in the ActorTasks tree
					return ErrActorTasksNotFound 
				}
				ActorTasks.Set(a.Id, existingActorTasks)
			}
		} else {
			// Actor tasks not found in the ActorTasks tree
			return ErrActorTasksNotFound 
		}
	}
	return nil
} 

func (a Actor) AssignActorToProject(wp WorkableProject) (err errors) {
	if ActorProjects.Size() != 0 {
		existingWorkableProjects, ok := ActorProjects.Get(a.Id)
		if !ok {
			existingWorkableProjects = []*WorkableProject{}
		}
		else {
			projects, ok := existingWorkableProjects([]*WorkableProject)
			if !ok {
				return ErrActorProjectsNotFound
			}
			existingWorkableProjects = projects
		}
		updatedProjects := append(existingWorkableProjects.([]*WorkableProject), wp)
		ActorProjects.Set(a.Id, updatedProjects)
	}
	return nil
} 

func (a Actor) UnassignActorFromProject(wp WorkableProject) (err errors) {
	if ActorProjects.Size() != 0 {
		existingActorProjects, exist := ActorProjects.Get(a.Id)
		if exist {

			var tindex int = -1
			for i, project := range existingActorProjects.([]*WorkableProject) {
				if wp.id == project.id {
					tindex = i
					break
				}
				if tindex != -1 {
					existingActorProjects = append(existingActorProjects.([]*WorkableProject)[:tindex], existingActorProjects.([]*WorkableProject)[tindex+1:]...)
				} else {
					// Actor projects not found in the ActorTasks tree
					return ErrActorProjectsNotFound 
				}
				ActorProjects.Set(a.Id, existingActorProjects)
			}
		} else {
			// Actor projects not found in the ActorTasks tree
			return ErrActorProjectsNotFound 
		}
	}
	return nil
} 

// getters

func GetActorById(actorId string) (a Actor, err errors) {
	if Actors.Size() != 0 {
		actor, exist := Actors.Get(actorId)
		if exist {
			return actor.(Actor), nil
		} else {
			retrun nil, ErrActorIdNotFound
		}

	}
	return nil, ErrActorIdNotFound
}

func GetAllActors()(actors string, err errors) {
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

func (a Actor) GetActorTeams() (actorTeams string, err errors) {
	actorTeams := []*Team

	if ActorTeams.Size() != 0 {
		existingActorTeams, exist := ActorTeams.Get(a.Id)
		if !exist {
			// if there's no record in ActorTeams, we don't have to return anything
			return nil, ErrActorTeamsNotFound
		} else {
			actorTeams = existingActorTeams
		}
	}

	if actorTeams.Size() != 0 {
		teamsObject := &TeamsObject {
			Teams: actorTeams,
		}
		marshalledTeams, merr := teamsObject.MarshalJSON()
		if merr != nil {
			return "", merr
		} 
		return string(marshalledTeams), nil
	}

	return "", ErrActorTeamsNotFound
}

func (a Actor) GetActorTasks() (actorTasks string, err errors) {

}

func (a Actor) GetActorProjects() (actorProjects string, err errors) {

}