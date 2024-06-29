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
	
	// Test editing an existing payment
	t.Run("Edit existing rewards points", func(t *testing.T) {
		updatedRPoints := RewardsPoint{Id: "1", ObjectId: "task1", ObjectType: "task", Amount: std.Coins{{Denom: "ugnot",  Amount: 100}}, Status: "Disbursed",}
		err := updatedRPoints.UpdateRewardsPoints()
		if err != nil {
			t.Errorf("expected no error, got %v", err)
		}

		// Verify the payment is updated
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

func Test_RemoveRewardsPoints(t *testing.T) {
	
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

func Test_GetRewardsPointsByOjectId(t *testing.T) {

	point := RewardsPoint{Id: "1", ObjectId: "task1", ObjectType: "task", Amount: std.Coins{{Denom: "ugnot",  Amount: 100}}, Status: "Disbursed"}
	
	result, err := GetRewardsPointsByOjectId("task1", "task")
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if result.Id != point.Id || result.Status != point.Status {
		t.Errorf("Expected %v, got %v", point, result)
	}

	// Test with non-existing data
	result, err = GetRewardsPointsByOjectId("nonexistent", "task")
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if (result != RewardsPoint{}) {
		t.Errorf("Expected empty RewardsPoint, got %v", result)
	}
}

func Test_GetAllRewardsPoints(t *testing.T){

	// Initialize test data
	point1 := RewardsPoint{
		Id:         "1",
		ObjectId:   "task1",
		ObjectType: "task",
		Amount:     std.Coins{{Denom: "token", Amount: 20}},
		Status:     "Disbursed",
	}
	point2 := RewardsPoint{
		Id:         "2",
		ObjectId:   "task2",
		ObjectType: "task",
		Amount:     std.Coins{{Denom: "token", Amount: 30}},
		Status:     "Assigned",
	}

	point1.AddRewardsPoints()
	point2.AddRewardsPoints()

	// Test the function
	result, err := GetAllRewardsPoints()
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	// Define the expected result
	expectedResult := `{"rewardsPoints":[{"rewardsPointId":"1","objectId":"task1","objectType":"task","rewardsPointsAmount":"100ugnot","rewardsPointsStatus":"Disbursed"},{"rewardsPointId":"2","objectId":"task2","objectType":"task","rewardsPointsAmount":"30token","rewardsPointsStatus":"Assigned"}]}`
	if result != expectedResult {
		t.Errorf("Expected %v, got %v", expectedResult, result)
	}

	// Test with no rewards points
	point1.RemoveRewardsPoints()
	point2.RemoveRewardsPoints()
	
	result, err = GetAllRewardsPoints()
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}
	if result != `{"rewardsPoints":[]}` {
		t.Errorf("Expected empty rewards points, got %v", result)
	}
}

func Test_GetTotalRewardsPoints(t *testing.T) {
	
	// Add test data to the RewardsPoints tree.
	rewardsPoint1 := RewardsPoint{
		Id:         "1",
		ObjectId:   "task1",
		ObjectType: "task",
		Amount:     std.Coins{{Denom: "token", Amount: 10}},
		Status:     "Disbursed",
	}
	rewardsPoint2 := RewardsPoint{
		Id:         "2",
		ObjectId:   "task2",
		ObjectType: "task",
		Amount:     std.Coins{{Denom: "token", Amount: 20}},
		Status:     "Disbursed",
	}

	rewardsPoint1.AddRewardsPoints()
	rewardsPoint2.AddRewardsPoints()

	// Call the GetTotalRewardsPoints function.
	totalRewardsPoints, err := GetTotalRewardsPoints()
	if err != nil {
		t.Errorf("Failed to get total rewards points: %v", err)
	}

	// Check if the total rewards points is correct.
	expectedTotal := std.Coins{{Denom: "token", Amount: 30}}
	if !totalRewardsPoints.IsEqual(expectedTotal) {
		t.Errorf("Expected total rewards points to be %v, but got %v", totalRewardsPoints, expectedTotal)
	}
}

func (coins std.Coins) IsEqual(other std.Coins) bool {
	if len(coins) != len(other) {
		return false
	}
	for i := range coins {
		if coins[i].Denom != other[i].Denom || coins[i].Amount != other[i].Amount {
			return false
		}
	}
	return true
}