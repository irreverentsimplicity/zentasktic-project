package zentasktic_project


import (
	"strconv"
	"std"
)

// this is a convenience wrapper on top of the functions declared in the actors file


var currentUserID int

func init() {
	currentUserID = 0
}

// users

// Wrapper function to add an Actor
func AddActorWrap(userName string, userAddress string) error {
	userID := incrementUserID()
	actor := &Actor{
		Id:      strconv.Itoa(userID),
		Name:    userName,
		Address: std.Address(userAddress),
	}
	// Logic to store the Actor within zentasktic_project as needed
	return actor.AddActor()
}

// Wrapper function to edit an Actor
func EditActorWrap(userId string, userName string, userAddress string) error {
	actor, err := GetActorById(userId)
	if err != nil {
		return err
	}
	actor.Name = userName
	actor.Address = std.Address(userAddress)
	// Logic to update the Actor within zentasktic_project as needed
	return actor.EditActor()
}

// Wrapper function to remove an Actor
func RemoveActorWrap(userId string) error {
	actor, err := GetActorById(userId)
	if err != nil {
		return err
	}
	// Logic to remove the Actor within zentasktic_project as needed
	return actor.RemoveActor()
}

// Wrapper function to add an Actor to a team using zteams
func AddActorToTeamWrap(userId string, teamId string) error {
	actor, err := GetActorById(userId)
	if err != nil {
		return err
	}
	team, terr := TeamManager.getTeam(std.Address(teamId))
	if terr != nil {
		return terr
	}
	// Convert Actor to zteams User and add to the team
	user := actor.ToUser()
	return TeamManager.AddUserToTeam(team.Address, user, team.Owner)
}

// Wrapper function to remove an Actor from a team using zteams
func RemoveActorFromTeamWrap(userId string, teamId string) error {
	actor, err := GetActorById(userId)
	if err != nil {
		return err
	}
	team, terr := TeamManager.getTeam(std.Address(teamId))
	if terr != nil {
		return terr
	}
	// Convert Actor to zteams User and remove from the team
	return TeamManager.RemoveUserFromTeam(team.Address, actor.Address, team.Owner)
}

func incrementUserID() int {
	currentUserID++
	return currentUserID
}