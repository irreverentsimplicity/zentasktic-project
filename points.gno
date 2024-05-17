package zentasktic_project

import (
	"strconv"
	"errors"
	"std"

	"gno.land/p/demo/avl"
)

type RewardsPoint struct {
    Id				string `json:"rewardsPointId"`
    ObjectId 		string `json:"objectId"`
    ObjectType      string `json:"objectType"`
	Amount  		std.Coins `json:"rewardsPointAmount"`
    Status			string `json:"rewardsPointStatus"`            // assigned / released / unused, etc
}

var (
	RewardsPoints avl.Tree // rp.Id -> rp
)

func (rp RewardsPoint) AddRewardsPoints() (err error) { 
	// implementation
	
	if RewardsPoints.Size() != 0 {
		existingRP, exist := RewardsPoints.Get(rp.Id)
		if exist {
			return ErrRewardsPointIdAlreadyExists
		}
	}
	RewardsPoints.Set(rp.Id, rp)
	return nil
}

func (rp RewardsPoint) RemoveRewardsPoints() (err error) { 
	// implementation
	existingRP := RewardsPoint{}
	if RewardsPoints.Size() != 0 {
		existingRP, exist := RewardsPoints.Get(rp.Id)
		if !exist {
			return ErrRewardsPointIdNotFound
		}
	}

	_, removed := RewardsPoints.Remove(rp.Id)
	if !removed {
		return ErrRewardsPointNotRemoved
	}
	return nil
}

func (rp RewardsPoint) UpdateRewardsPoints() (err error) { 
	// implementation, get rpm by Id and replace the object
	existingRP := RewardsPoint{}
	if RewardsPoints.Size() != 0 {
		existingRP, exist := RewardsPoints.Get(rp.Id)
		if !exist {
			return ErrRewardsPointIdNotFound
		}
	}
	
	RewardsPoints.Set(rp.Id, rp)
	return nil
}

// getters

func GetRewardsPointsByOjectId(objectId string, objectType string) (rp RewardsPoint, err error) {
	// implementation
	rewardsPoints := RewardsPoint{}

	// Iterate over the RewardPoints AVL tree to see if we have a matching ObjectId.
	
	RewardsPoints.Iterate("", "", func(key string, value interface{}) bool {
		if rewardsPointsItem, ok := value.(RewardsPoint); ok {
			if rewardsPointsItem.ObjectId == objectId && rewardsPointsItem.ObjectType == objectType {
				rewardsPoints = rewardsPointsItem
			}
		}
		return false // Continue iteration until all nodes have been visited.
	})

	return rewardsPoints, nil
}

func GetAllRewardsPoints() (rewardsPoints string, err error){
	// implementation
	var allRewardsPoints []*RewardsPoint

	// Iterate over the RewardsPoints AVL tree to collect all RewardsPoint objects.
	RewardsPoints.Iterate("", "", func(key string, value interface{}) bool {
		if rewardsPoint, ok := value.(RewardsPoint); ok {
			allRewardsPoints = append(allRewardsPoints, &rewardsPoint)
		}
		return false // Continue iteration until all nodes have been visited.
	})

	// Create a RewardsPontsObject with all collected team.
	rewardsPointsObject := &RewardsPointsObject{
		RewardsPoints: allRewardsPoints,
	}

	// Use the custom MarshalJSON method to marshal the rewards points into JSON.
	marshalledRwardsPoints, merr := rewardsPointsObject.MarshalJSON()
	if merr != nil {
		return "", merr
	} 
	return string(marshalledRwardsPoints), nil
}

func GetTotalRewardsPoints() (rewardsPoints int, err error){
	total := std.Coins{}

	// Iterate over the RewardPoints AVL tree to find matching ObjectId and ObjectType records.
	RewardsPoints.Iterate("", "", func(key string, value interface{}) bool {
		if rewardsPointsItem, ok := value.(RewardsPoint); ok {
			total = total.Add(rewardsPointsItem.Amount)
		}
		return false // Continue iteration until all nodes have been visited.
	})

	return total.(int), nil
}