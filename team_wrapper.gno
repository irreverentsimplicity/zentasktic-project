package zentasktic_project


import (
	"strconv"
)

// this is a convenience wrapper on top of the functions declared in the teams file


var currentTeamID int

func init() {
	currentTeamID = 0
}

// teams

func AddTeamWrap(teamName string) error {
	teamID := incrementTeamID()
	t := &Team{
		Id:          strconv.Itoa(teamID),
		Name:        teamName,
	}
	return t.AddTeam()
}


func EditTeamWrap(teamId string, teamName string) error {
	teamToEdit, err := GetTeamById(teamId)
	if err != nil {
		return err	
	}
	teamToEdit.Name = teamName;
	return teamToEdit.EditTeam()
}

func RemoveTeamWrap(teamId string) error {
	teamToRemove, err := GetTeamById(teamId)
	if err != nil {
		return err
	}
	return teamToRemove.RemoveTeam()
}

func incrementTeamID() int {
	currentTeamID++
	return currentTeamID
}