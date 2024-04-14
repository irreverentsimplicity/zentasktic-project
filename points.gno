package zentasktic_project

import (
	"strconv"
	"errors"

	"gno.land/p/demo/avl"
)

type RewardsPoint struct {
    Id              string `json:"rewardsPointId"`
    ObjectId 			string `json:"objectId"`
    ObjectType       string `json:"objectType"`
	Amount  		string `json:"rewardsPointAmount"`
    Status          string `json:"rewardsPointStatus"`            // assigned / released / unused, etc
}

var {
	RewardPoints avl.Tree // rp.Id -> rp
}

func (rp RewardsPoint) AddRewardsPoints() (err errors) { 

}

func (rp RewardsPoint) RemoveRewardsPoints() (err errors) { 

}

// getters

func GetRewardsPointsByOjectId(objectId string, objectType string) (rp RewardsPoint, err errors) {

}

func GetAllRewardsPoints() (rewardsPoints int, err errors){

}