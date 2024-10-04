# Proposed data structures rich types for a DAO / team

These types are intended to be used in the Decide realm.

## Actor

The basic working unit for an individual. Actors can be team members, or individual contributors.

```
type Actor struct {
    Id 		    string `json:"actorId"`
    TeamId 		string `json:""`
    Name 		string `json:"actorName"`
    // github handle?
}
```

## Team

Teams are collective entities, they may or may not have actors assigned. The latest implementation uses `p/zteams` for team management.

## WorkHour

WorkHours are abstract time measurements assignable to a Task / Projet. They may or may not be combined with Actors or Teams.

```
type WorkHour struct {
    Id                  string `json:"workHourId"`
    ObjectId            string `json:"objectId"`
    ObjectType          string `json:"objectType"` // Task, Project
    Amount              string `json:"workHourAmount"`
}
```

## RewardsPoints

RewardsPoints are abstract denominations for how much a certain task or project should be worth on completion. They may or may not be assigned to Actors or Teams, but they are releasable once a Task / Project is completed (moving a Task / Project with assigned RewardsPoints from Do to a Collection releases the assigned rewards points from the total existing).

```
type RewardsPoint struct {
    Id              string `json:"rewardsPointId"`
    ObjectId 		string `json:"objectId"`
    ObjectType      string `json:"objectType"`
    Amount          string `json:"rewardsPointAmount"`
    Status          string `json:"rewardsPointStatus"`            // assigned / released / unused, etc
}
```

## Resources

Resources are abstract denominations for what needs to be spent, e.g. money, electricity, for a specific Task / Project.

```
type Resource struct {
    Id 			string `json:"resourceId"`
    Name        string `json:"resourceName"`   // money / fixed expenses etc
}
```
