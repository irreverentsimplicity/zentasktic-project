package zentasktic_project

import (
	"testing"

    "gno.land/p/demo/avl"
	"gno.land/p/demo/zentasktic"
)

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

/*
func Test_RemoveActor(t *testing.T) {
	// Helper function to add an actor and related data
	addTestActor := func(actor Actor, team *Team, task *WorkableTask, project *WorkableProject) {
		Actors.Set(actor.Id, actor)
		if team != nil {
			ActorTeams.Set(actor.Id, []*Team{team})
			Members.Set(team.Id, []*Actor{&actor})
		}
		if task != nil {
			ActorTasks.Set(actor.Id, []*WorkableTask{task})
		}
		if project != nil {
			ActorProjects.Set(actor.Id, []*WorkableProject{project})
		}
	}

	actorId := "1"
	actor := Actor{Id: actorId, Name: "Test Actor", Address: "testaddress"}
	team := &Team{Id: "team1"}
	task := &WorkableTask{Task: zentasktic.Task{Id: "task1"}}
	project := &WorkableProject{Project: zentasktic.Project{Id: "project1"}}

	// Test removing an actor that exists in all collections
	t.Run("Remove existing actor", func(t *testing.T) {
		// Set up the environment
		addTestActor(actor, team, task, project)

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
}*/

