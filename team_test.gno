package zentasktic_project

import (
	"testing"

    "gno.land/p/demo/avl"
	"gno.land/p/demo/zentasktic"
)

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

func Test_GetTeamById(t *testing.T) {
    teamId := "team1"
	expectedTeam := Team{Id: "team1", Name: "Team One", Members: []*Actor{}}
	
	// Test retrieving an existing team
	t.Run("Get existing team", func(t *testing.T) {
		team, err := GetTeamById(teamId)
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



