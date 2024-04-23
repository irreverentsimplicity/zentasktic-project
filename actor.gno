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
	ActorTasks avl.Tree // a.id -> []*WorkableTasks
	ActorProjects avl.Tree // a.id -> []*WorkableProjects
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
	
} 

// getters

func GetActorById(actorId string) (a Actor, err errors) {

}

func GetAllActors()(actors string, err) {

}

func (a Actor) GetActorTeams() (actorTeams string, err errors) {

}

func (a Actor) GetActorTasks() (actorTasks string, err errors) {

}

func (a Actor) GetActorProjects() (actorProjects string, err errors) {

}