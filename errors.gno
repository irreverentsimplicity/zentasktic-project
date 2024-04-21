package zentasktic_project

import "errors"

var (
	ErrWorkDurationNotFound             	= errors.New("Could not find work duration")
	ErrWorkDurationNotRemoved           	= errors.New("Could not remove work duration")
)