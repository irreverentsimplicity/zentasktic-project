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

func AddActorWrap(userName string, userAddress string) error {
	userID := incrementUserID()
	a := &Actor{
		Id:          strconv.Itoa(userID),
		Name:        userName,
		Address: 	 std.Address(userAddress),
	}
	return a.AddActor()
}


func EditActorWrap(userId string, userName string, userAddress string) error {
	userToEdit, err := GetActorById(userId)
	if err != nil {
		return err	
	}
	userToEdit.Name = userName;
	userToEdit.Address = std.Address(userAddress);
	return userToEdit.EditActor()
}

func RemoveActorWrap(userId string) error {
	userToRemove, err := GetActorById(userId)
	if err != nil {
		return err
	}
	return userToRemove.RemoveActor()
}

func AddActorToTeamWrap(userId string, teamId string) error {
	userToAdd, err := GetActorById(userId)
	if err != nil {
		return err
	}
	teamToAddTo, terr := GetTeamById(teamId)
	if terr != nil {
		return terr
	}
	return userToAdd.AddActorToTeam(teamToAddTo)
}

func RemoveActorFromTeamWrap(userId string, teamId string) error {
	userToRemove, err := GetActorById(userId)
	if err != nil {
		return err
	}
	teamToRemoveFrom, terr := GetTeamById(teamId)
	if terr != nil {
		return terr
	}
	return userToRemove.RemoveActorFromTeam(teamToRemoveFrom)
}

func incrementUserID() int {
	currentUserID++
	return currentUserID
}