extends Node

var currency: int = 0
var speed_tier: int = 0
var damage_tier: int = 0
const MAX_TIER: int = 5

func add_currency(amount: int) -> void:
	currency += amount

func can_afford(cost: int) -> bool:
	return currency >= cost

func purchase_upgrade(tier_var: String, cost: int) -> bool:
	if not can_afford(cost):
		return false
	currency -=cost
	set(tier_var, get(tier_var)+1)
	return true

func reset() -> void:
	currency = 0
	speed_tier = 0
	damage_tier = 0
