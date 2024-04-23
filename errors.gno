package zentasktic_project

import "errors"

var (
	ErrWorkDurationNotFound             	= errors.New("Could not find work duration")
	ErrWorkDurationNotRemoved           	= errors.New("Could not remove work duration")
	ErrActorIdAlreadyExists					= errors.New("Actor id already exists")
	ErrActorIdNotFound						= errors.New("Actor id not found")
	ErrActorTeamsNotFound					= errors.New("Could not find actor teams")
	ErrActorTeamsNotRemoved					= errors.New("Actor teams could not be removed")
	ErrActorTasksNotFound					= errors.New("Could not find actor tasks")
	ErrActorTasksNotRemoved					= errors.New("Actor tasks could not be removed")
	ErrActorProjectsNotRemoved				= errors.New("Actor projects could not be removed")
	ErrActorNotRemoved						= errors.New("Actor could not be removed")
	ErrTeamIdNotFound						= errors.New("Team id not found")
	ErrTeamMembersNotFound					= errors.New("Team members not found")
	ErrActorProjectsNotFound				= errors.New("Could not find actor projects")
	
)