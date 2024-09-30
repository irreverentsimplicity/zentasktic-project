package zentasktic_project

import (
    "errors"
    "strconv"
    "gno.land/p/demo/users"
    "gno.land/p/demo/avl"
    "gno.land/p/demo/zentasktic"
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
func AddTeamWrap(teamName string) error {
    teamID := incrementTeamID()
    team := &zteams.Team{
        Address:  std.Address(strconv.Itoa(teamID)), // Converting ID to address for demo purposes
        TeamName: teamName,
        Owner:    std.Address("OwnerAddress"), // Placeholder for owner address, update as needed
    }
    return TeamManager.AddTeam(team)
}

// Wrapper function to edit a team
func EditTeamWrap(teamId string, teamName string) error {
    team, err := TeamManager.GetTeam(std.Address(teamId))
    if err != nil {
        return err
    }
    team.TeamName = teamName
    TeamManager.Teams.Set(team.Address.String(), team)
    return nil
}

// Wrapper function to remove a team
func RemoveTeamWrap(teamId string) error {
    team, err := TeamManager.GetTeam(std.Address(teamId))
    if err != nil {
        return err
    }
    TeamManager.Teams.Remove(team.Address.String())
    TeamManager.Members.Remove(team.Address.String())
    return nil
}

// Wrapper function to assign a task to a team
func AssignTeamToTaskWrap(teamId string, taskId string) error {
    team, err := TeamManager.GetTeam(std.Address(teamId))
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
func UnassignTeamFromTaskWrap(teamId string, taskId string) error {
    team, err := TeamManager.GetTeam(std.Address(teamId))
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
