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