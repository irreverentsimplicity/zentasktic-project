package zentasktic_project

import (
    "errors"
    "gno.land/p/demo/zteams"
    "std"
)

var (
    currentTeamID int
)

func init() {
    currentTeamID = 0
}

// Wrapper function to add a team
func AddTeamWrap(teamName string, teamAddress string, ownerAddress string) error {
    team := &zteams.Team{
        Address:  std.Address(teamAddress), 
        TeamName: teamName,
        Owner:    std.Address(ownerAddress),
    }
    return TeamManager.AddTeam(team)
}

// Wrapper function to edit a team
func EditTeamWrap( string, teamName string) error {
    team, err := TeamManager.GetTeam(std.Address())
    if err != nil {
        return err
    }
    team.TeamName = teamName
    TeamManager.Teams.Set(team.Address.String(), team)
    return nil
}

// Wrapper function to remove a team
func RemoveTeamWrap( string) error {
    team, err := TeamManager.GetTeam(std.Address())
    if err != nil {
        return err
    }
    TeamManager.Teams.Remove(team.Address.String())
    TeamManager.Members.Remove(team.Address.String())
    return nil
}

// Wrapper function to assign a task to a team
func AssignTeamToTaskWrap( string, taskId string) error {
    team, err := TeamManager.GetTeam(std.Address())
    if err != nil {
        return err
    }
    
    task, terr := GetTaskById(taskId) // Assuming existing task fetching logic
    if terr != nil {
        return terr
    }

    tasks, _ := TeamTasks.Get(team.Address.String())
    var updatedTasks []WorkableTask
    if tasks != nil {
        updatedTasks = tasks.([]WorkableTask)
    }
    for _, existingTask := range updatedTasks {
        if existingTask.Id == task.Id {
            return nil // Task already assigned to team
        }
    }
    updatedTasks = append(updatedTasks, task)
    TeamTasks.Set(team.Address.String(), updatedTasks)
    return nil
}

// Wrapper function to unassign a task from a team
func UnassignTeamFromTaskWrap( string, taskId string) error {
    team, err := TeamManager.GetTeam(std.Address())
    if err != nil {
        return err
    }

    tasks, exist := TeamTasks.Get(team.Address.String())
    if !exist {
        return errors.New("team task not found")
    }

    updatedTasks := tasks.([]WorkableTask)
    for i, task := range updatedTasks {
        if task.Id == taskId {
            updatedTasks = append(updatedTasks[:i], updatedTasks[i+1:]...)
            if len(updatedTasks) == 0 {
                TeamTasks.Remove(team.Address.String())
            } else {
                TeamTasks.Set(team.Address.String(), updatedTasks)
            }
            return nil
        }
    }
    return errors.New("team task not found")
}

// Wrapper function to increment team ID (legacy)
func incrementTeamID() int {
    currentTeamID++
    return currentTeamID
}
