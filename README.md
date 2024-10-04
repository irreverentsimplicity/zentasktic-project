# ZenTasktic Project

An opinionated, complete project management solution for the gno ecosystem as `r/zentasktic_project`. This implementation enriches the data types with teams and specific resources (work hours, reward points).

## Data types

There are 4 new data types defined: `Actor`, `Team`, `WorkDuration` and `RewardsPoint`. Underneath, `Actor` uses `p/users` enriching with a local `Id`. `Team` use `p/zteams`.

```
type Actor struct {
	Id 		    	string `json:"actorId"`
	user		user.User,
}
```

```
type WorkDuration struct {
	Id				string `json:"workDurationId"`
    ObjectId 		string `json:"objectId"`
    ObjectType      string `json:"objectType"` // Task, Project
	Duration  		time.Duration `json:"workDuration"`
	Workable   		Workable      `json:"-"`
}
```

```
type RewardsPoint struct {
    Id				string `json:"rewardsPointId"`
    ObjectId 		string `json:"objectId"`
    ObjectType      string `json:"objectType"`
	Amount  		std.Coins `json:"rewardsPointAmount"`
    Status			string `json:"rewardsPointStatus"`            // assigned / released / unused, disbursed, etc
}
```

We are wrapping all the `p/zentasktic` package functions, so they are transparently available in the realm, all related code is in `wrapper.gno`.

## Example Workflow

This is an example on how to use the implementation in a new realm.

```
package myzenproject

import (
	"fmt"
	"gno.land/r/demo/zentasktic_project"
)

func main() {
	// Create a new actor
	actor := zentasktic_project.Actor{
		Id:   "user-1",
		Name: "John Doe",
		Address: "g1fptq8jnypzm4udqd6d8luja5w44js4jqncdg9g",
	}

	// Add the user
	err := actor.AddActor()
	if err != nil {
		fmt.Println(err)
		return
	}

    // Create a new team
	team := zentasktic_project.Team{
		Id:   "team-1",
		Name: "Fabulous Team",
	}

	// Add the team
	err := team.AddTeam()
	if err != nil {
		fmt.Println(err)
		return
	}

    // Add the actor to the team
	err := actor.AddActorToTeam(team)
	if err != nil {
		fmt.Println(err)
		return
	}

	// Assign the actor to a task
	task := zentasktic_project.WorkableTask{
		Id:   "task-1",
		Name: "Task 1",
	}
	err = actor.AssignActorToTask(&task)
	if err != nil {
		fmt.Println(err)
		return
	}

    // Assign the actor to a project
	project := zentasktic_project.WorkableProject{
		Id:   "project-1",
		Name: "Project 1",
	}
	err = actor.AssignActorToProject(&project)
	if err != nil {
		fmt.Println(err)
		return
	}

    // Assign the team to a task
	task2 := zentasktic_project.WorkableTask{
		Id:   "task-2",
		Name: "Task 2",
	}
	err = team.AssignATeamToTask(&task2)
	if err != nil {
		fmt.Println(err)
		return
	}

	// Assign the actor to a project
	project := zentasktic_user.WorkableProject{
		Id:   "project-1",
		Name: "Project 1",
	}
	err = actor.AssignActorToProject(&project)
	if err != nil {
		fmt.Println(err)
		return
	}

    // Assign the team to a project
	project2 := zentasktic_user.WorkableProject{
		Id:   "project-2",
		Name: "Project 2",
	}
	err = team.AssignTeamToProject(&project)
	if err != nil {
		fmt.Println(err)
		return
	}

	// Get all actor
	users, err := GetAllActors()
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(users)

	// Get actor tasks
	tasks, err := actor.GetActorTasks()
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(tasks)

	// Get actor projects
	projects, err := actor.GetActorProjects()
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(projects)

    // Get actor teams
	teams, err := actor.GetActorTeams()
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(teams)
}

```