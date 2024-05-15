package zentasktic_project

import (
	"strconv"
	"bytes"
	"errors"
	"std"
)

type ActorsObject struct {
	Actors	[]Actor
}

type TeamsObject struct {
	Teams	[]*Team
}

func (a Actor) MarshalJSON() ([]byte, error) {

	var b bytes.Buffer
	
	b.WriteByte('{')

	b.WriteString(`"actorId":"`)
	b.WriteString(a.Id)
	b.WriteString(`",`)

	b.WriteString(`"actorName":"`)
	b.WriteString(a.Name)
	b.WriteString(`",`)

	b.WriteString(`"actorAddress":"`)
	b.WriteString(string(a.Address))
	b.WriteString(`"`)

	b.WriteByte('}')

	return b.Bytes(), nil
}

func (ao ActorsObject) MarshalJSON() ([]byte, error) {
	var b bytes.Buffer

	b.WriteString(`{"actors":[`)
	
	for i, actor := range ao.Actors {
		if i > 0 {
			b.WriteString(`,`)
		}
		actorJSON, cerr := actor.MarshalJSON()
		if cerr == nil {
			b.WriteString(string(actorJSON))
		}
	}

	b.WriteString(`]}`)

	return b.Bytes(), nil
}

func (t Team) MarshalJSON() ([]byte, error) {

	var b bytes.Buffer
	
	b.WriteByte('{')

	b.WriteString(`"teamId":"`)
	b.WriteString(t.Id)
	b.WriteString(`",`)

	b.WriteString(`"teamName":"`)
	b.WriteString(t.Name)
	b.WriteString(`",`)

	b.WriteString(`"teamMembers":[`)

	if len(t.Members) != 0 {
		for i, actor := range t.Members {
			if i > 0 {
				b.WriteString(`,`)
			}
			teamMemberJSON, perr := actor.MarshalJSON()
			if perr == nil {
				b.WriteString(string(teamMemberJSON))
			}
		}
	}

	b.WriteString(`],`)

	b.WriteByte('}')

	return b.Bytes(), nil
}

func (to TeamsObject) MarshalJSON() ([]byte, error) {
	var b bytes.Buffer

	b.WriteString(`{"teams":[`)
	
	for i, team := range to.Teams {
		if i > 0 {
			b.WriteString(`,`)
		}
		teamJSON, cerr := team.MarshalJSON()
		if cerr == nil {
			b.WriteString(string(teamJSON))
		}
	}

	b.WriteString(`]}`)

	return b.Bytes(), nil
}