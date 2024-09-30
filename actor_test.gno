package zentasktic_project

import (
	"testing"

    "gno.land/p/demo/avl"
	"gno.land/p/demo/zentasktic"
)

var ztm *zentasktic.ZTaskManager
var zpm *zentasktic.ZProjectManager

func init() {
    ztm = zentasktic.NewZTaskManager()
    zpm = zentasktic.NewZProjectManager()
}
/*
func Test_AddActor(t *testing.T) {

    actor := Actor{Id: "1", Name: "Developer", Address: "g1jvsnur7haahze6n6z3gzfdzu5yelr9rj3dajs7",}

    // Test adding an actor successfully.
    err := actor.AddActor()
    if err != nil {
        t.Errorf("Failed to add actor: %v", err)
    }

    // Test adding a duplicate actor.
    cerr := actor.AddActor()
    if cerr != ErrActorIdAlreadyExists {
        t.Errorf("Expected ErrActorIdAlreadyExists, got %v", cerr)
    }
}

func Test_EditActor(t *testing.T) {
	// Initialize Actors store with an existing actor
	actorId := "1"
	initialActor := Actor{Id: actorId, Name: "Initial Name", Address: "g1jvsnur7haahze6n6z3gzfdzu5yelr9rj3dajs7"}
	Actors.Set(actorId, initialActor)

	// Test editing an existing actor
	t.Run("Edit existing actor", func(t *testing.T) {
		updatedActor := Actor{Id: actorId, Name: "Updated Name", Address: "newAddress"}
		err := updatedActor.EditActor()
		if err != nil {
			t.Errorf("expected no error, got %v", err)
		}

		// Verify the actor is updated
		editedActor, exist := Actors.Get(actorId)
		if !exist {
			t.Errorf("expected actor to exist")
		}
		if editedActor.(Actor).Name != "Updated Name" {
			t.Errorf("expected actor name to be 'Updated Name', got %s", editedActor.(Actor).Name)
		}
		if editedActor.(Actor).Address != "newAddress" {
			t.Errorf("expected actor address to be 'newAddress', got %s", editedActor.(Actor).Address)
		}
	})

	// Test editing a non-existing actor
	t.Run("Edit non-existing actor", func(t *testing.T) {
		nonExistingActor := Actor{Id: "999", Name: "Non Existing", Address: "someAddress"}
		err := nonExistingActor.EditActor()
		if err != ErrActorIdNotFound {
			t.Errorf("expected error %v, got %v", ErrActorIdNotFound, err)
		}
	})
}

func Test_RemoveActor(t *testing.T) {
	
	actorId := "2"
	actor := Actor{Id: actorId, Name: "Test Actor", Address: "testaddress",}
	team := Team{Id: "team1", Name: "Team one", Members: []*Actor{},}
	task := WorkableTask{Task: zentasktic.Task{
        Id:        "task1",
        ProjectId: "project1",
        ContextId: "context1",
        RealmId:   "realm1",
        Body:      "This is a task body",
        Due:       "2023-12-31",
        Alert:     "2023-12-30",
    },}
	project := WorkableProject{Project: zentasktic.Project{
        Id:        "project1",
        ContextId: "context1",
        RealmId:   "realm1",
        Tasks:     []zentasktic.Task{},
        Body:      "This is the project body",
        Due:       "2024-12-31",
    },}

	// Test removing an actor that exists in all collections
	t.Run("Remove existing actor", func(t *testing.T) {
        // setting up the environment
        actor.AddActor()
        actor.AddActorToTeam(team)
        actor.AssignActorToTask(&task)
        actor.AssignActorToProject(&project)
		
		err := actor.RemoveActor()
		if err != nil {
			t.Errorf("Failed to remove actor: %v", err)
		}

		// Verify actor is removed from all collections
		if _, exist := Actors.Get(actorId); exist {
			t.Errorf("Expected actor to be removed from Actors")
		}
		if _, exist := ActorTeams.Get(actorId); exist {
			t.Errorf("Expected actor to be removed from ActorTeams")
		}
		if members, exist := Members.Get(team.Id); exist {
			for _, teamActor := range members.([]*Actor) {
				if teamActor.Id == actorId {
					t.Errorf("Expected actor to be removed from team members")
				}
			}
		}
		if _, exist := ActorTasks.Get(actorId); exist {
			t.Errorf("Expected actor to be removed from ActorTasks")
		}
		if _, exist := ActorProjects.Get(actorId); exist {
			t.Errorf("Expected actor to be removed from ActorProjects")
		}
	})

	// Test removing an actor that does not exist
	t.Run("Remove non-existing actor", func(t *testing.T) {
		nonExistingActor := Actor{Id: "999", Name: "Non Existing Actor", Address: "nonexistingaddress"}
		err := nonExistingActor.RemoveActor()
		if err != ErrActorIdNotFound {
			t.Errorf("Expected error %v, got %v", ErrActorIdNotFound, err)
		}
	})
}

func Test_GetActorById(t *testing.T) {
    actorId := "1"
	expectedActor := Actor{Id: actorId, Name: "Updated Name", Address: "newAddress",}
	
	// Test retrieving an existing actor
	t.Run("Get existing actor", func(t *testing.T) {
		actor, err := GetActorById(actorId)
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}
		if actor != expectedActor {
			t.Errorf("Expected actor %v, got %v", expectedActor, actor)
		}
	})

	// Test retrieving a non-existing actor
	t.Run("Get non-existing actor", func(t *testing.T) {
		nonExistingActorId := "999"
		_, err := GetActorById(nonExistingActorId)
		if err != ErrActorIdNotFound {
			t.Errorf("Expected error %v, got %v", ErrActorIdNotFound, err)
		}
	})
}

func Test_GetActorTeams(t *testing.T) {
	
	actor, _ := GetActorById("1")
	team1 := Team{Id: "team1", Name: "Team One", Members: []*Actor{}}
	team2 := Team{Id: "team2", Name: "Team Two", Members: []*Actor{}}
    
	// Test retrieving teams for an existing actor
	t.Run("Get existing actor teams", func(t *testing.T) {
		// Set up the environment
        team1.AddTeam()
        team2.AddTeam()
		actor.AddActorToTeam(team1)

		teamsJSON, err := actor.GetActorTeams()
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}

		expectedJSON := `{"teams":[{"teamId":"team1","teamName":"Team One","teamMembers":[{"actorId":"1","actorName":"Updated Name","actorAddress":"newAddress"}]}]}`
		if teamsJSON != expectedJSON {
			t.Errorf("Expected JSON %s, got %s", expectedJSON, teamsJSON)
		}
	})

	// Test retrieving teams for an actor with no teams
	t.Run("Get actor with no teams", func(t *testing.T) {
		emptyActorId := "2"
		emptyActor := Actor{Id: emptyActorId}
		
		_, err := emptyActor.GetActorTeams()
		if err != ErrActorTeamsNotFound {
			t.Errorf("Expected error %v, got %v", ErrActorTeamsNotFound, err)
		}
	})

	// Test retrieving teams for an actor with incorrect type
	t.Run("Get actor teams with incorrect type", func(t *testing.T) {
		incorrectTypeActorId := "3"
		ActorTeams.Set(incorrectTypeActorId, "incorrect type")

		incorrectTypeActor := Actor{Id: incorrectTypeActorId}
		_, err := incorrectTypeActor.GetActorTeams()
		if err != ErrActorTeamsIncorrectType {
			t.Errorf("Expected error %v, got %v", ErrActorTeamsIncorrectType, err)
		}
	})
}

func Test_AddActorToTeam(t *testing.T) {
	
	// Test adding an actor to a team successfully
	t.Run("Add actor to team", func(t *testing.T) {
		actor, _ := GetActorById("1")
        team, _ := GetTeamById("team2")

		// Add the actor to the team
		err := actor.AddActorToTeam(team)
		if err != nil {
			t.Fatalf("Failed to add actor to team: %v", err)
		}

		// Verify the actor is added to ActorTeams
		existingActorTeams, exist := ActorTeams.Get(actor.Id)
		if !exist {
			t.Errorf("Expected actor to be in ActorTeams")
		}
		if teams, ok := existingActorTeams.([]*Team); ok {
            // we already added the actor to team1 in the previous test function
            // so we have 2 entries in the team slice
			if len(teams) != 2 || teams[1].Id != team.Id {
				t.Errorf("Expected team to be added to ActorTeams, got %v", teams)
			}
		} else {
			t.Errorf("Expected ActorTeams to contain []*Team, got %T", existingActorTeams)
		}

		// Verify the actor is added to Members of the team
		existingMembers, exist := Members.Get(team.Id)
		if !exist {
			t.Errorf("Expected team to be in Members")
		}
		if members, ok := existingMembers.([]*Actor); ok {
			if len(members) != 1 || members[0].Id != actor.Id {
				t.Errorf("Expected actor to be added to team members, got %v", members)
			}
		} else {
			t.Errorf("Expected Members to contain []*Actor, got %T", existingMembers)
		}
	})

    
	// Test adding an actor that does not exist
	t.Run("Add non-existing actor to team", func(t *testing.T) {
		team, _ := GetTeamById("1")
		// Attempt to add a non-existing actor to the team
		nonExistingActor := Actor{Id: "non-existing", Name: "Non-Existing"}
		err := nonExistingActor.AddActorToTeam(team)
		if err != ErrActorIdNotFound {
			t.Errorf("Expected error %v, got %v", ErrActorIdNotFound, err)
		}
	})
}

func Test_RemoveActorFromTeam(t *testing.T) {
	
	actor, _ := GetActorById("1")
	team, _ := GetTeamById("team1")

	// Test removing an actor from a team successfully
	t.Run("Remove actor from team", func(t *testing.T) {
		// actor is already added to team in the previous test functions

		// Remove the actor from the team
		err := actor.RemoveActorFromTeam(team)
		if err != nil {
			t.Fatalf("Failed to remove actor from team: %v", err)
		}

		// Verify the actor is removed from ActorTeams
		existingActorTeams, exist := ActorTeams.Get(actor.Id)
		if !exist {
			t.Errorf("Expected actor to be in ActorTeams")
		}
		if teams, ok := existingActorTeams.([]*Team); ok {
            // actor is added to team2, so there is only 1 team in ActorTeams that has it
			if len(teams) != 1 {
				t.Errorf("Expected team to be removed from ActorTeams, got %v", teams)
			}
		} else {
			t.Errorf("Expected ActorTeams to contain []*Team, got %T", existingActorTeams)
		}

		// Verify the actor is removed from Members of the team
		existingMembers, exist := Members.Get(team.Id)
		if !exist {
			t.Errorf("Expected team to be in Members")
		}
		if members, ok := existingMembers.([]*Actor); ok {
			if len(members) != 0 {
				t.Errorf("Expected actor to be removed from team members, got %v", members)
			}
		} else {
			t.Errorf("Expected Members to contain []*Actor, got %T", existingMembers)
		}
	})

	// Test removing an actor that does not exist
	t.Run("Remove non-existing actor from team", func(t *testing.T) {
	
		// Attempt to remove a non-existing actor from the team
		nonExistingActor := Actor{Id: "non-existing", Name: "Non-Existing"}
		err := nonExistingActor.RemoveActorFromTeam(team)
		if err != ErrActorIdNotFound {
			t.Errorf("Expected error %v, got %v", ErrActorIdNotFound, err)
		}
	})

	// Test removing an actor from a team that does not exist
	t.Run("Remove actor from non-existing team", func(t *testing.T) {
		
		// Attempt to remove the actor from a non-existing team
		nonExistingTeam := Team{Id: "non-existing", Name: "Non-Existing"}
		err := actor.RemoveActorFromTeam(nonExistingTeam)
		if err != ErrTeamIdNotFound {
			t.Errorf("Expected error %v, got %v", ErrTeamIdNotFound, err)
		}
	})
}

func Test_AssignActorToTask(t *testing.T) {
    actor, _ := GetActorById("1")
	task := WorkableTask{Task: zentasktic.Task{
        Id:        "task1",
        ProjectId: "project1",
        ContextId: "context1",
        RealmId:   "realm1",
        Body:      "This is a task body",
        Due:       "2023-12-31",
        Alert:     "2023-12-30",
    },}
	project := WorkableProject{Project: zentasktic.Project{
        Id:        "project1",
        ContextId: "context1",
        RealmId:   "realm1",
        Tasks:     []zentasktic.Task{},
        Body:      "This is the project body",
        Due:       "2024-12-31",
    },}

	// Test assigning a task to an actor with no existing tasks
	t.Run("Assign task to actor with no existing tasks", func(t *testing.T) {
		ztm.AddTask(task.Task)
        zpm.AddProject(project.Project)
		err := actor.AssignActorToTask(&task)
		if err != nil {
			t.Errorf("Failed to assign task: %v", err)
		}

		existingTasks, exist := ActorTasks.Get(actor.Id)
		if !exist {
			t.Errorf("Expected tasks to be assigned to actor")
		}
	})
}

func Test_UnassignActorFromTask(t *testing.T) {
	actor, err := GetActorById("1")
	if err != nil {
		t.Fatalf("Failed to get actor: %v", err)
	}
	taskToUnassignFrom, terr := ztm.GetTaskById("task1")
	if terr != nil {
        t.Fatalf("Failed to get task: %v", terr)
    }
	wt := WorkableTask{Task: taskToUnassignFrom}
	// Ensure the task is initially assigned to the actor
	existingActorTasks, exist := ActorTasks.Get(actor.Id)
	if !exist {
		t.Fatal("Actor tasks not initialized correctly")
	}

	tasks, ok := existingActorTasks.([]*WorkableTask)
	if len(tasks) == 0 || tasks[0].Id != wt.Id {
		t.Fatalf("Expected task not found in actor tasks. Got: %v", tasks)
	}

	// Test unassigning the task from the actor
	uerr := actor.UnassignActorFromTask(&wt)
	if uerr != nil {
		t.Errorf("Failed to unassign task: %v", uerr)
	}
	
	// Verify the task is unassigned
	existingActorTasks, _ = ActorTasks.Get(actor.Id)
	tasks, ok = existingActorTasks.([]*WorkableTask)
	if !ok || len(tasks) != 0 {
		t.Fatalf("Expected no tasks in actor tasks. Got: %v", tasks)
	}
	
	// Test unassigning a task that does not exist
	err = actor.UnassignActorFromTask(&wt)
	if err != ErrActorTasksNotFound {
		t.Errorf("Expected ErrActorTasksNotFound, got: %v", err)
	}
}

func Test_GetActorTasks(t *testing.T) {
	actor, _ := GetActorById("1")

	// Test case when there are no tasks assigned to the actor
	t.Run("No tasks assigned to actor", func(t *testing.T) {
		_, err := actor.GetActorTasks()
		if err != ErrActorTasksNotFound {
			t.Errorf("Expected ErrActorTasksNotFound, got %v", err)
		}
	})

	// Adding tasks to the actor
    task := WorkableTask{Task: zentasktic.Task{
        Id:        "task1",
        ProjectId: "project1",
        ContextId: "context1",
        RealmId:   "realm1",
        Body:      "This is a task body",
        Due:       "2023-12-31",
        Alert:     "2023-12-30",
    },}
    ztm.AddTask(task.Task)
	err := actor.AssignActorToTask(&task)
	
	// Test case when tasks are assigned to the actor
	t.Run("Tasks assigned to actor", func(t *testing.T) {
		tasks, err := actor.GetActorTasks()
		if err != nil {
			t.Errorf("Failed to get actor tasks: %v", err)
		}
		expectedTasks := `{"tasks":[{"taskId":"task1","taskProjectId":"project1","taskContextId":"context1","taskRealmId":"realm1","taskBody":"This is a task body","taskDue":"2023-12-31","taskAlert":"2023-12-30"}]}`
		if tasks != expectedTasks {
			t.Errorf("Expected %v, got %v", expectedTasks, tasks)
		}
	})
}

func Test_AssignActorToProject(t *testing.T) {
    actor, _ := GetActorById("1")
    wproject, err := zpm.GetProjectById("project1")
    if err != nil {
        t.Fatalf("Failed to get project: %v", err)
    }

	// Test assigning a project to an actor with no existing projects
	t.Run("Assign project to actor with no existing projects", func(t *testing.T) {
		
        wp := WorkableProject{Project: wproject}
		err := actor.AssignActorToProject(&wp)
		if err != nil {
			t.Errorf("Failed to assign task: %v", err)
		}

		existingProjects, exist := ActorProjects.Get(actor.Id)
		if !exist {
			t.Errorf("Expected projects to be assigned to actor")
		}
	})
}

func Test_UnassignActorFromProject(t *testing.T) {
	actor, err := GetActorById("1")
	if err != nil {
		t.Fatalf("Failed to get actor: %v", err)
	}
	projectToUnassignFrom, terr := zpm.GetProjectById("project1")
	if terr != nil {
        t.Fatalf("Failed to get project: %v", terr)
    }
	wp := WorkableProject{Project: projectToUnassignFrom}
	// Ensure the task is initially assigned to the actor
	existingActorProjects, exist := ActorProjects.Get(actor.Id)
	if !exist {
		t.Fatal("Actor projects not initialized correctly")
	}

	projects, ok := existingActorProjects.([]*WorkableProject)
	if len(projects) == 0 || projects[0].Id != wp.Id {
		t.Fatalf("Expected project not found in actor projects. Got: %v", projects)
	}

	// Test unassigning the project from the actor
	uerr := actor.UnassignActorFromProject(&wp)
	if uerr != nil {
		t.Errorf("Failed to unassign project: %v", uerr)
	}
	
	// Verify the project is unassigned
	existingActorProjects, _ = ActorProjects.Get(actor.Id)
	projects, ok = existingActorProjects.([]*WorkableProject)
	if !ok || len(projects) != 0 {
		t.Fatalf("Expected no projets in actor projects. Got: %v", projects)
	}
	
	// Test unassigning a project that does not exist
	err = actor.UnassignActorFromProject(&wp)
	if err != ErrActorProjectsNotFound {
		t.Errorf("Expected ErrActorProjectsNotFound, got: %v", err)
	}
}

func Test_GetActorProjects(t *testing.T) {
	actor, _ := GetActorById("1")

	// Test case when there are no projects assigned to the actor
	t.Run("No projects assigned to actor", func(t *testing.T) {
		_, err := actor.GetActorProjects()
		if err != ErrActorProjectsNotFound {
			t.Errorf("Expected ErrActorProjectsNotFound, got %v", err)
		}
	})

	// Adding projects to the actor
    project := WorkableProject{Project: zentasktic.Project{
        Id:        "project1",
        ContextId: "context1",
        RealmId:   "realm1",
        Tasks:     []zentasktic.Task{},
        Body:      "This is the project body",
        Due:       "2024-12-31",
    },}
    zpm.AddProject(project.Project)
	err := actor.AssignActorToProject(&project)
	
	// Test case when projects are assigned to the actor
	t.Run("Projects assigned to actor", func(t *testing.T) {
		projects, err := actor.GetActorProjects()
		if err != nil {
			t.Errorf("Failed to get actor projects: %v", err)
		}
		expectedProjects := `{"projects":[{"projectId":"project1","projectContextId":"context1","projectRealmId":"realm1","projectTasks":[],"projectBody":"This is the project body","projectDue":"2024-12-31"}]}`
		if projects != expectedProjects {
			t.Errorf("Expected %v, got %v", expectedProjects, projects)
		}
	})
}

func Test_GetAllActors(t *testing.T) {
	
	t.Run("With actors", func(t *testing.T) {
		actors, err := GetAllActors()
		if err != nil {
			t.Errorf("Unexpected error: %v", err)
		}
		if actors == "" {
			t.Errorf("Expected JSON array of actors, got empty string")
		}
		expected := `{"actors":[{"actorId":"1","actorName":"Updated Name","actorAddress":"newAddress"}]}`
		if actors != expected {
			t.Errorf("Expected %s, got %s", expected, actors)
		}
	})
}
	*/
