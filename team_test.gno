package zentasktic_project

import (
	"testing"

    "gno.land/p/demo/avl"
	"gno.land/p/demo/zentasktic"
)

/*
func Test_AddTeam(t *testing.T) {
	team4 := Team{Id: "team4", Name: "Team Four", Members: []*Actor{},}

    // Test adding a team successfully.
    err := team4.AddTeam()
    if err != nil {
        t.Errorf("Failed to add team: %v", err)
    }

    // Test adding a duplicate team.
    cerr := team4.AddTeam()
    if cerr != ErrTeamIdAlreadyExists {
        t.Errorf("Expected ErrTeamIdAlreadyExists, got %v", cerr)
    }
}

func Test_EditTeam(t *testing.T) {
	// initialize
	team4, _ := GetTeamById("team4")

	// Test editing an existing team
	t.Run("Edit existing team", func(t *testing.T) {
		updatedTeam := Team{Id: "team4", Name: "Team Four Updated", Members: []*Actor{},}
		err := updatedTeam.EditTeam()
		if err != nil {
			t.Errorf("expected no error, got %v", err)
		}

		// Verify the team is updated
		editedTeam, exist := Teams.Get("team4")
		if !exist {
			t.Errorf("expected team to exist")
		}
		if editedTeam.(Team).Name != "Team Four Updated" {
			t.Errorf("expected actor name to be 'Team Four Updated', got %s", editedTeam.(Team).Name)
		}
	})

	// Test editing a non-existing actor
	t.Run("Edit non-existing team", func(t *testing.T) {
		nonExistingTeam := Team{Id: "999", Name: "Non Existing", Members: []*Actor{},}
		err := nonExistingTeam.EditTeam()
		if err != ErrTeamIdNotFound {
			t.Errorf("expected error %v, got %v", ErrTeamIdNotFound, err)
		}
	})
}

func Test_RemoveTeam(t *testing.T) {
	team4, _ := GetTeamById("team4")
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
	team4.AssignTeamToTask(&task)
	team4.AssignTeamToProject(&project)

	// Test removing a team // Test removing an existing team
	t.Run("Remove existing team", func(t *testing.T) {
		err := team4.RemoveTeam()
		if err != nil {
			t.Errorf("Failed to remove team: %v", err)
		}

		if _, exist := Members.Get(team4.Id); exist {
			t.Errorf("Expected team to be removed from Members")
		}
		if _, exist := TeamTasks.Get(team4.Id); exist {
			t.Errorf("Expected team to be removed from TeamTasks")
		}
		if _, exist := TeamProjects.Get(team4.Id); exist {
			t.Errorf("Expected team to be removed from TeamProjects")
		}
		if existingActorTeams, exist := ActorTeams.Get(actor.Id); exist {
			teams := existingActorTeams.([]*Team)
			for _, team := range teams {
				if team.Id == team4.Id {
					t.Errorf("Expected team to be removed from ActorTeams")
				}
			}
		}
		if _, exist := Teams.Get(team4.Id); exist {
			t.Errorf("Expected team to be removed from Teams")
		}
	})

	// Test removing a team that does not exist
	t.Run("Remove non-existing team", func(t *testing.T) {
		nonExistingTeam := Team{Id: "999", Name: "Non Existing", Members: []*Actor{},}
		err := nonExistingTeam.RemoveTeam()
		if err != ErrTeamIdNotFound {
			t.Errorf("Expected error %v, got %v", ErrTeamIdNotFound, err)
		}
	})
}

func Test_AssignTeamToTask(t *testing.T) {
    team1, _ := GetTeamById("team1")
	taskToAssignTo, terr := ztm.GetTaskById("task1")
	if terr != nil {
        t.Fatalf("Failed to get project: %v", terr)
    }
	wt := WorkableTask{Task: taskToAssignTo}
	// Test assigning a task to a team with no existing tasks
	t.Run("Assign task to team with no existing tasks", func(t *testing.T) {
		err := team1.AssignTeamToTask(&wt)
		if err != nil {
			t.Errorf("Failed to assign task: %v", err)
		}

		existingTasks, exist := TeamTasks.Get(team1.Id)
		if !exist {
			t.Errorf("Expected tasks to be assigned to team")
		}
	})
}

func Test_UnassignTeamFromTask(t *testing.T) {
	team1, err := GetTeamById("team1")
	if err != nil {
		t.Fatalf("Failed to get team: %v", err)
	}
	taskToUnassignFrom, terr := ztm.GetTaskById("task1")
	if terr != nil {
        t.Fatalf("Failed to get task: %v", terr)
    }
	wt := WorkableTask{Task: taskToUnassignFrom}
	// Ensure the task is initially assigned to the team
	existingTeamTasks, exist := TeamTasks.Get(team1.Id)
	if !exist {
		t.Fatal("Team tasks not initialized correctly")
	}

	tasks, ok := existingTeamTasks.([]*WorkableTask)
	if len(tasks) == 0 || tasks[0].Id != wt.Id {
		t.Fatalf("Expected task not found in team tasks. Got: %v", tasks)
	}

	// Test unassigning the task from the team
	uerr := team1.UnassignTeamFromTask(&wt)
	if uerr != nil {
		t.Errorf("Failed to unassign task: %v", uerr)
	}
	
	// Verify the task is unassigned
	existingTeamTasks, _ = TeamTasks.Get(team1.Id)
	tasks, ok = existingTeamTasks.([]*WorkableTask)
	if !ok || len(tasks) != 0 {
		t.Fatalf("Expected no tasks in team tasks. Got: %v", tasks)
	}
	
	// Test unassigning a task that does not exist
	err = team1.UnassignTeamFromTask(&wt)
	if err != ErrTeamTasksNotFound {
		t.Errorf("Expected ErrTeamTasksNotFound, got: %v", err)
	}
}

func Test_GetTeamTasks(t *testing.T) {
	team, _ := GetTeamById("team1")

	// Test case when there are no tasks assigned to the team
	t.Run("No tasks assigned to team", func(t *testing.T) {
		_, err := team.GetTeamTasks()
		if err != ErrTeamTasksNotFound {
			t.Errorf("Expected ErrTeamTasksNotFound, got %v", err)
		}
	})

	// Adding tasks to the team
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
	err := team.AssignTeamToTask(&task)
	
	// Test case when tasks are assigned to the team
	t.Run("Tasks assigned to team", func(t *testing.T) {
		tasks, err := team.GetTeamTasks()
		if err != nil {
			t.Errorf("Failed to get team tasks: %v", err)
		}
		expectedTasks := `{"tasks":[{"taskId":"task1","taskProjectId":"project1","taskContextId":"context1","taskRealmId":"realm1","taskBody":"This is a task body","taskDue":"2023-12-31","taskAlert":"2023-12-30"}]}`
		if tasks != expectedTasks {
			t.Errorf("Expected %v, got %v", expectedTasks, tasks)
		}
	})
}

func Test_AssignTeamToProject(t *testing.T) {
    team1, _ := GetTeamById("team1")
    wproject, err := zpm.GetProjectById("project1")
    if err != nil {
        t.Fatalf("Failed to get project: %v", err)
    }

	// Test assigning a project to a team with no existing projects
	t.Run("Assign project to team with no existing projects", func(t *testing.T) {
		
        wp := WorkableProject{Project: wproject}
		err := team1.AssignTeamToProject(&wp)
		if err != nil {
			t.Errorf("Failed to assign task: %v", err)
		}

		existingProjects, exist := TeamProjects.Get(team1.Id)
		if !exist {
			t.Errorf("Expected projects to be assigned to team")
		}
	})
}

func Test_UnassignTeamFromProject(t *testing.T) {
	team1, err := GetTeamById("team1")
	if err != nil {
		t.Fatalf("Failed to get team: %v", err)
	}
	projectToUnassignFrom, terr := zpm.GetProjectById("project1")
	if terr != nil {
        t.Fatalf("Failed to get project: %v", terr)
    }
	wp := WorkableProject{Project: projectToUnassignFrom}
	// Ensure the project is initially assigned to the team
	existingTeamProjects, exist := TeamProjects.Get(team1.Id)
	if !exist {
		t.Fatal("Team projects not initialized correctly")
	}

	projects, ok := existingTeamProjects.([]*WorkableProject)
	if len(projects) == 0 || projects[0].Id != wp.Id {
		t.Fatalf("Expected project not found in team projects. Got: %v", projects)
	}

	// Test unassigning the task from the team
	uerr := team1.UnassignTeamFromProject(&wp)
	if uerr != nil {
		t.Errorf("Failed to unassign project: %v", uerr)
	}
	
	// Verify the project is unassigned
	existingTeamProjects, _ = TeamProjects.Get(team1.Id)
	projects, ok = existingTeamProjects.([]*WorkableProject)
	if !ok || len(projects) != 0 {
		t.Fatalf("Expected no projects in team projects. Got: %v", projects)
	}
	
	// Test unassigning a project that does not exist
	err = team1.UnassignTeamFromProject(&wp)
	if err != ErrTeamProjectsNotFound {
		t.Errorf("Expected ErrTeamProjectsNotFound, got: %v", err)
	}
}

func Test_GetTeamProjects(t *testing.T) {
	team, _ := GetTeamById("team1")

	// Test case when there are no projects assigned to the team
	t.Run("No projects assigned to team", func(t *testing.T) {
		_, err := team.GetTeamProjects()
		if err != ErrTeamProjectsNotFound {
			t.Errorf("Expected ErrTeamProjectsNotFound, got %v", err)
		}
	})

	// Adding projects to the team
    project := WorkableProject{Project: zentasktic.Project{
        Id:        "project1",
        ContextId: "context1",
        RealmId:   "realm1",
        Tasks:     []zentasktic.Task{},
        Body:      "This is the project body",
        Due:       "2024-12-31",
    },}
    zpm.AddProject(project.Project)
	err := team.AssignTeamToProject(&project)
	
	// Test case when projects are assigned to the team
	t.Run("Projects assigned to team", func(t *testing.T) {
		projects, err := team.GetTeamProjects()
		if err != nil {
			t.Errorf("Failed to get team projects: %v", err)
		}
		expectedProjects := `{"projects":[{"projectId":"project1","projectContextId":"context1","projectRealmId":"realm1","projectTasks":[],"projectBody":"This is the project body","projectDue":"2024-12-31"}]}`
		if projects != expectedProjects {
			t.Errorf("Expected %v, got %v", expectedProjects, projects)
		}
	})
}

func Test_GetTeamById(t *testing.T) {
     := "team1"
	expectedTeam := Team{Id: "team1", Name: "Team One", Members: []*Actor{}}
	
	// Test retrieving an existing team
	t.Run("Get existing team", func(t *testing.T) {
		team, err := GetTeamById()
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}
		if team.Id != expectedTeam.Id && team.Name != expectedTeam.Name {
			t.Errorf("Expected team %v, got %v", expectedTeam, team)
		}
	})
	
	// Test retrieving a non-existing team
	t.Run("Get non-existing team", func(t *testing.T) {
		nonExistingTeamId := "999"
		_, err := GetTeamById(nonExistingTeamId)
		if err != ErrTeamIdNotFound {
			t.Errorf("Expected error %v, got %v", ErrTeamIdNotFound, err)
		}
	})
}

func Test_GetAllTeams(t *testing.T) {
	
	t.Run("With teams", func(t *testing.T) {
		teams, err := GetAllTeams()
		if err != nil {
			t.Errorf("Unexpected error: %v", err)
		}
		if teams == "" {
			t.Errorf("Expected JSON array of teams, got empty string")
		}
		expected := `{"teams":[{"":"team1","teamName":"Team One","teamMembers":[]},{"":"team2","teamName":"Team Two","teamMembers":[]}]}`
		if teams != expected {
			t.Errorf("Expected %s, got %s", expected, teams)
		}
	})
}*/





