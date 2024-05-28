package zentasktic_project

import (
	"testing"
	"std"
	"time"

    "gno.land/p/demo/avl"
	"gno.land/p/demo/zentasktic"
)

func Test_AddWorkDuration(t *testing.T) {

    sampleTask := WorkableTask{
		Task: zentasktic.Task{Id: "1", RealmId: "1", Body: "First task", ContextId: "1",},
	}

	workDurationTask := WorkDuration{
		Id:         "wd-001",
		ObjectId:   "1",
		ObjectType: "Task",
		Duration:   2 * time.Hour,
		Workable:   &sampleTask,
	}

    // Test adding a work duration successfully.
    err := workDurationTask.AddWorkDuration()
    if err != nil {
        t.Errorf("Failed to add work duration: %v", err)
    }

    // Test adding a duplicate work duration object.
    cerr := workDurationTask.AddWorkDuration()
    if cerr != ErrWorkDurationIdAlreadyExists {
        t.Errorf("Expected ErrWorkDurationIdAlreadyExists, got %v", cerr)
    }
}

func Test_EditWorkDuration(t *testing.T) {
	sampleTask := WorkableTask{
		Task: zentasktic.Task{Id: "1", RealmId: "1", Body: "First task", ContextId: "1",},
	}
	updatedWorkDurationTask := WorkDuration{
		Id:         "wd-001",
		ObjectId:   "1",
		ObjectType: "Task",
		Duration:   4 * time.Hour,
		Workable:   &sampleTask,
	}
	t.Run("Edit existing work duration", func(t *testing.T) {
		
		
		err := updatedWorkDurationTask.EditWorkDuration()
		if err != nil {
			t.Errorf("expected no error, got %v", err)
		}

		// Verify the work duration is updated
		editedWDuration, exist := WorkDurations.Get(updatedWorkDurationTask.Id)
		if !exist {
			t.Errorf("expected work duration to exist")
		}
		if editedWDuration.(WorkDuration).Duration != (4 * time.Hour) {
			t.Errorf("expected work duration Duration to be '4 x time.Hour', got %s", editedWDuration.(WorkDuration).Duration)
		}
	})

	// Test editing a non-existing work duration point
	t.Run("Edit non-existing work duration object", func(t *testing.T) {
		nonExistingWD := WorkDuration{
			Id:         "non-existing",
			ObjectId:   "non-existing",
			ObjectType: "non-exitsting",
			Duration:   4 * time.Hour,
			Workable:   nil,
		}
		
		err := nonExistingWD.EditWorkDuration()
		if err != ErrWorkDurationNotFound {
			t.Errorf("expected error %v, got %v", ErrWorkDurationNotFound, err)
		}
	})
}

func Test_RemoveWorkDuration(t *testing.T) {
	
	sampleTask := WorkableTask{
		Task: zentasktic.Task{Id: "2", RealmId: "1", ProjectId: "1", Body: "Second task", ContextId: "1", Due: "due", Alert: "alert",},
	}

	workDurationTask := WorkDuration{
		Id:         "wd-003",
		ObjectId:   "3",
		ObjectType: "Task",
		Duration:   2 * time.Hour,
		Workable:   &sampleTask,
	}

	// Test removing a work duration
	
	t.Run("Remove existing work duration", func(t *testing.T) {
        // setting up the environment
        workDurationTask.AddWorkDuration()
		
		err := workDurationTask.RemoveWorkDuration()
		if err != nil {
			t.Errorf("Failed to remove work duration object: %v", err)
		}
	})

	
	// Test removing a work duration object that does not exist
	t.Run("Remove non-existing work duration object", func(t *testing.T) {
		nonExistingWD := WorkDuration{
			Id:         "non-existing",
			ObjectId:   "non-existing",
			ObjectType: "non-exitsting",
			Duration:   4 * time.Hour,
			Workable:   nil,
		}
		err := nonExistingWD.RemoveWorkDuration()
		if err != ErrWorkDurationNotFound {
			t.Errorf("Expected error %v, got %v", ErrWorkDurationNotFound, err)
		}
	})
}

func Test_GetWorkDurationByObjectId(t *testing.T){
	
	sampleTask := WorkableTask{
		Task: zentasktic.Task{Id: "1", RealmId: "1", Body: "First task", ContextId: "1",},
	}
	
	workDurationTask := WorkDuration{
		Id:         "wd-001",
		ObjectId:   "1",
		ObjectType: "Task",
		Duration:   2 * time.Hour,
		Workable:   &sampleTask,
	}
	result, err := GetWorkDurationByOjectId("1", "Task")
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if result.ObjectId != workDurationTask.ObjectId || result.ObjectType != workDurationTask.ObjectType {
		t.Errorf("Expected %v, got %v", workDurationTask, result)
	}

	// Test with non-existing data
	result, err = GetWorkDurationByOjectId("nonexistent", "Task")
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if (result != WorkDuration{}) {
		t.Errorf("Expected empty WorkDuration, got %v", result)
	}
}