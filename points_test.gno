package zentasktic_project

import (
	"testing"
	"std"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/zentasktic"
)

func Test_AddRewardsPoints(t *testing.T) {
	// Explicitly set field names when creating struct instances
	testCoin := std.NewCoin("ugnot", 100)
	point := RewardsPoint{
		Id:         "1",
		ObjectId:   "task1",
		ObjectType: "task",
		Amount:     testCoin,
		Status:     "Allocated",
	}

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
	t.Run("Edit existing rewards points", func(t *testing.T) {
		// Explicitly set field names when creating struct instances
		updatedCoin := std.NewCoin("ugnot", 100)
		updatedRPoints := RewardsPoint{
			Id:         "1",
			ObjectId:   "task1",
			ObjectType: "task",
			Amount:     updatedCoin,
			Status:     "Disbursed",
		}
		err := updatedRPoints.UpdateRewardsPoints()
		if err != nil {
			t.Errorf("expected no error, got %v", err)
		}

		// Verify the payment is updated
		editedRPoints, exist := RewardsPoints.Get(updatedRPoints.Id)
		if !exist {
			t.Errorf("expected rewards points to exist")
		}
		if editedRPoints.(RewardsPoint).Status != "Disbursed" {
			t.Errorf("expected rewards points status to be 'Disbursed', got %s", editedRPoints.(RewardsPoint).Status)
		}
	})

	t.Run("Edit non-existing rewards point object", func(t *testing.T) {
		// Explicitly set field names when creating struct instances
		testCoin2 := std.NewCoin("non-existing", 100)
		nonExistingRP := RewardsPoint{
			Id:         "999",
			ObjectId:   "non-existing",
			ObjectType: "non-existing",
			Amount:     testCoin2,
			Status:     "non-existing",
		}
		err := nonExistingRP.UpdateRewardsPoints()
		if err != ErrRewardsPointIdNotFound {
			t.Errorf("expected error %v, got %v", ErrRewardsPointIdNotFound, err)
		}
	})
}

func Test_RemoveRewardsPoints(t *testing.T) {
	rpId := "2"
	testCoin3 := std.NewCoin("ugnot", 400)
	point := RewardsPoint{
		Id:         rpId,
		ObjectId:   "project1",
		ObjectType: "project",
		Amount:     testCoin3,
		Status:     "Allocated",
	}

	t.Run("Remove existing rewards point", func(t *testing.T) {
		// setting up the environment
		point.AddRewardsPoints()

		err := point.RemoveRewardsPoints()
		if err != nil {
			t.Errorf("Failed to remove rewards points object: %v", err)
		}
	})

	t.Run("Remove non-existing rewards point object", func(t *testing.T) {
		testCoin4 := std.NewCoin("non-existing", 100)
		nonExistingRP := RewardsPoint{
			Id:         "999",
			ObjectId:   "non-existing",
			ObjectType: "non-existing",
			Amount:     testCoin4,
			Status:     "non-existing",
		}
		err := nonExistingRP.RemoveRewardsPoints()
		if err != ErrRewardsPointIdNotFound {
			t.Errorf("Expected error %v, got %v", ErrRewardsPointIdNotFound, err)
		}
	})
}

func Test_GetRewardsPointsByOjectId(t *testing.T) {
	testCoin5 := std.NewCoin("ugnot", 100)
	point := RewardsPoint{
		Id:         "1",
		ObjectId:   "task1",
		ObjectType: "task",
		Amount:     testCoin5,
		Status:     "Disbursed",
	}

	// Ensure the point is added for retrieval
	point.AddRewardsPoints()

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

func Test_GetAllRewardsPoints(t *testing.T) {
	testCoin6 := std.NewCoin("ugnot", 100)
	testCoin7 := std.NewCoin("ugnot", 30)
	point1 := RewardsPoint{
		Id:         "1",
		ObjectId:   "task1",
		ObjectType: "task",
		Amount:     testCoin6,
		Status:     "Disbursed",
	}
	point2 := RewardsPoint{
		Id:         "2",
		ObjectId:   "task2",
		ObjectType: "task",
		Amount:     testCoin7,
		Status:     "Assigned",
	}

	point2.AddRewardsPoints()

	result := GetAllRewardsPoints()
	

	expectedResult := `{"rewardsPoints":[{"rewardsPointId":"1","objectId":"task1","objectType":"task","rewardsPointsAmount":"100ugnot","rewardsPointsStatus":"Disbursed"},{"rewardsPointId":"2","objectId":"task2","objectType":"task","rewardsPointsAmount":"30ugnot","rewardsPointsStatus":"Assigned"}]}`
	if result != expectedResult {
		t.Errorf("Expected %v, got %v", expectedResult, result)
	}

	// Test with no rewards points
	
	point2.RemoveRewardsPoints()
	point1.RemoveRewardsPoints()

	result = GetAllRewardsPoints()
	
	if result != `{"rewardsPoints":[]}` {
		t.Errorf("Expected empty rewards points, got %v", result)
	}
}

func Test_GetTotalRewardsPoints(t *testing.T) {
	testCoin8 := std.NewCoin("ugnot", 10)
	testCoin9 := std.NewCoin("ugnot", 20)
	rewardsPoint1 := RewardsPoint{
		Id:         "1",
		ObjectId:   "task1",
		ObjectType: "task",
		Amount:     testCoin8,
		Status:     "Disbursed",
	}
	rewardsPoint2 := RewardsPoint{
		Id:         "2",
		ObjectId:   "task2",
		ObjectType: "task",
		Amount:     testCoin9,
		Status:     "Disbursed",
	}

	rewardsPoint1.AddRewardsPoints()
	rewardsPoint2.AddRewardsPoints()

	totalRewardsPoints, err := GetTotalRewardsPoints()
	if err != nil {
		t.Errorf("Failed to get total rewards points: %v", err)
	}

	expectedTotal := std.NewCoin("ugnot", 30)
	if !totalRewardsPoints.IsEqual(expectedTotal) {
		t.Errorf("Expected total rewards points to be %v, but got %v", expectedTotal, totalRewardsPoints)
	}
}
