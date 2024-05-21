package zentasktic_project

import (
	"testing"
	"std"

    "gno.land/p/demo/avl"
	"gno.land/p/demo/zentasktic"
)

func Test_AddRewardsPoints(t *testing.T) {

    point := RewardsPoint{Id: "1", ObjectId: "task1", ObjectType: "task", Amount: std.Coins{{Denom: "ugnot",  Amount: 100}}, Status: "Allocated",}

    // Test adding a rewards point successfully.
    err := point.AddRewardsPoints()
    if err != nil {
        t.Errorf("Failed to add rewards points: %v", err)
    }

    // Test adding a duplicate rewards points object.
    cerr := point.AddRewardsPoints()
    if cerr != ErrRewardsPointIdAlreadyExists {
        t.Errorf("Expected ErrRewardsPointIdAlreadyExists, got %v", cerr)
    }
}

func Test_UpdateRewardsPoints(t *testing.T) {
	
	// Test editing an existing actor
	t.Run("Edit existing rewards points", func(t *testing.T) {
		updatedRPoints := RewardsPoint{Id: "1", ObjectId: "task1", ObjectType: "task", Amount: std.Coins{{Denom: "ugnot",  Amount: 100}}, Status: "Disbursed",}
		err := updatedRPoints.UpdateRewardsPoints()
		if err != nil {
			t.Errorf("expected no error, got %v", err)
		}

		// Verify the actor is updated
		editedRPoints, exist := RewardsPoints.Get(updatedRPoints.Id)
		if !exist {
			t.Errorf("expected rewards points to exist")
		}
		if editedRPoints.(RewardsPoint).ObjectId != "task1" {
			t.Errorf("expected rewards points status to be 'Disbursed', got %s", editedRPoints.(RewardsPoint).ObjectId)
		}
	})

	// Test editing a non-existing rewards point
	t.Run("Edit non-existing rewards point object", func(t *testing.T) {
		nonExistingRP := RewardsPoint{Id: "999", ObjectId: "non-existing", ObjectType: "non-existing", Amount: std.Coins{{Denom: "non-existing",  Amount: 100}}, Status: "non-existing",}
		err := nonExistingRP.UpdateRewardsPoints()
		if err != ErrRewardsPointIdNotFound {
			t.Errorf("expected error %v, got %v", ErrRewardsPointIdNotFound, err)
		}
	})
}

func Test_RemoveRwardsPoints(t *testing.T) {
	
	rpId := "2"
	point := RewardsPoint{Id: rpId, ObjectId: "project1", ObjectType: "project", Amount: std.Coins{{Denom: "ugnot",  Amount: 400}}, Status: "Allocated",}
	
	// Test removing a rewards point
	t.Run("Remove existing rewards point", func(t *testing.T) {
        // setting up the environment
        point.AddRewardsPoints()

		err := point.RemoveRewardsPoints()
		if err != nil {
			t.Errorf("Failed to remove rewards points object: %v", err)
		}
	})

	// Test removing a rewards point that does not exist
	t.Run("Remove non-existing rewards point object", func(t *testing.T) {
		nonExistingRP := RewardsPoint{Id: "999", ObjectId: "non-existing", ObjectType: "non-existing", Amount: std.Coins{{Denom: "non-existing",  Amount: 100}}, Status: "non-existing",}
		err := nonExistingRP.RemoveRewardsPoints()
		if err != ErrRewardsPointIdNotFound {
			t.Errorf("Expected error %v, got %v", ErrRewardsPointIdNotFound, err)
		}
	})
}
/*
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
}*/
