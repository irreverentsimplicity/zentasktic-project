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
	RewardPoints avl.Tree // rp.Id -> rp
)
/*
func (rp RewardsPoint) AddRewardsPoints() (err error) { 

}

func (rp RewardsPoint) RemoveRewardsPoints() (err error) { 

}

// getters

func GetRewardsPointsByOjectId(objectId string, objectType string) (rp RewardsPoint, err error) {

}

func GetAllRewardsPoints() (rewardsPoints int, err error){

}*/