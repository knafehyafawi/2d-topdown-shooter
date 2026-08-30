extends Node

var currency: int = 0
var speed_tier: int = 0
var damage_tier: int = 0
var health_tier: int = 0
var has_melee_weapon: bool = false

const MAX_TIER: int = 5
const MELEE_UNLOCK_COST: int = 100 #placeholder

func add_currency(amount: int) -> void:
	currency += amount

func can_afford(cost: int) -> bool:
	return currency >= cost

func purchase_upgrade(tier_var: String, cost: int) -> bool:
	if not can_afford(cost) or get(tier_var) >= MAX_TIER:
		return false
	currency -=cost
	set(tier_var, get(tier_var)+1)
	return true

func purchase_melee_unlock() -> bool:
	if has_melee_weapon or not can_afford(MELEE_UNLOCK_COST):
		return false
	currency -= MELEE_UNLOCK_COST
	has_melee_weapon = true
	return has_melee_weapon

func reset() -> void:
	currency = 0
	speed_tier = 0
	damage_tier = 0
	health_tier = 0
	has_melee_weapon = false
