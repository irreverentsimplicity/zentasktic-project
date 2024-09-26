package zentasktic_project

import (
	"std"
	"strconv"
	"errors"
)

// this is a convenience wrapper on top of the functions declared in the actors file


var currentRewardID int

func init() {
	currentRewardID = 0
}

// reward points

func AddRewardsPointsWrap(objectId string, objectType string, denom string, amount string) error {
	rewardID := incrementRewardID()
	intValue, err := strconv.Atoi(amount)
		if err != nil {
			return errors.New("invalid amount field")
		}
	amountInt := int64(intValue)
	reward := std.Coin{
		Denom: denom,
		Amount: amountInt,
	}
	rp := &RewardsPoint {
		Id:          strconv.Itoa(rewardID),
		ObjectId: objectId,
		ObjectType: objectType,
		Amount: reward,
		Status: "assigned",
	}
	return rp.AddRewardsPoints()
}

func UpdateRewardsPointsWrap(rewardId string, objectId string, objectType string, denom string, amount string) error {
	intValue, err := strconv.Atoi(amount)
		if err != nil {
			return errors.New("invalid amount field")
		}
	amountInt := int64(intValue)
	reward := std.Coin{
		Denom: denom,
		Amount: amountInt,
	}
	rp := &RewardsPoint {
		Id: rewardId,
		ObjectId: objectId,
		ObjectType: objectType,
		Amount: reward,
		Status: "updated",
	}
	if amountInt <= 0 {
		return rp.RemoveRewardsPoints()
	}
	return rp.UpdateRewardsPoints()
}

func incrementRewardID() int {
	currentRewardID++
	return currentRewardID
}