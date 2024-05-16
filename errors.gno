package zentasktic_project

import "errors"

var (
	ErrWorkDurationNotFound             	= errors.New("Could not find work duration")
	ErrWorkDurationNotRemoved           	= errors.New("Could not remove work duration")
	ErrWorkDurationsEmpty		           	= errors.New("There are no work durations registered")
	ErrActorIdAlreadyExists					= errors.New("Actor id already exists")
	ErrTeamIdAlreadyExists					= errors.New("Team id already exists")
	ErrActorIdNotFound						= errors.New("Actor id not found")
	ErrActorTeamsNotFound					= errors.New("Could not find actor teams")
	ErrActorTeamsIncorrectType				= errors.New("Incorrect type for ActorTeams")
	ErrActorTasksIncorrectType				= errors.New("Incorrect type for ActorTasks")
	ErrTeamTasksIncorrectType				= errors.New("Incorrect type for TeamTasks")
	ErrTeamProjectsIncorrectType			= errors.New("Incorrect type for TeamProjects")
	ErrActorProjectsIncorrectType			= errors.New("Incorrect type for ActorProjects")
	ErrActorTeamsNotRemoved					= errors.New("Actor teams could not be removed")
	ErrActorTasksNotFound					= errors.New("Could not find actor tasks")
	ErrTeamTasksNotFound					= errors.New("Could not find team tasks")
	ErrActorTasksNotRemoved					= errors.New("Actor tasks could not be removed")
	ErrTeamTasksNotRemoved					= errors.New("Team tasks could not be removed")
	ErrActorProjectsNotRemoved				= errors.New("Actor projects could not be removed")
	ErrTeamProjectsNotRemoved				= errors.New("Team projects could not be removed")
	ErrActorNotRemoved						= errors.New("Actor could not be removed")
	ErrTeamNotRemoved						= errors.New("Team could not be removed")
	ErrTeamMembersNotRemoved				= errors.New("Team member could not be removed")
	ErrTeamIdNotFound						= errors.New("Team id not found")
	ErrTeamMembersNotFound					= errors.New("Team members not found")
	ErrActorProjectsNotFound				= errors.New("Could not find actor projects")
	ErrTeamProjectsNotFound					= errors.New("Could not find team projects")
	
)