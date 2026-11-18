# GameData.gd (autoload)
extends Node

signal coins_changed(total: int)

const LEVELS: Array[String] = [
	"res://scene/computer/apps/spaceRPG/spaceRPG.tscn",
	"res://scene/computer/apps/spaceRPG/level2.tscn",
	"res://scene/computer/apps/spaceRPG/level3.tscn",
]
const COINS_PER_PUZZLE: int = 5
const COINS_PER_LEVEL: int = 10
const UPGRADE_COST_GROWTH: float = 1.5
const MAX_UPGRADE_LEVEL: int = 5

# What each upgrade level gives you.
const FUEL_PER_LEVEL: float = 0.75   # extra seconds of thruster fuel
const SPEED_PER_LEVEL: float = 25.0  # extra movement speed
# Hints: level 1 = none, level 2 = 1 hint per puzzle, level 3 = 2, ...

var coins: int = 0

# Progress through LEVELS
var current_level: int = 0
var level_cleared: bool = false

# Upgrade state. Every upgrade starts at level 1 (no bonus).
var upgrades: Dictionary = {
	"booster": {"level": 1, "cost": 10},
	"hints": {"level": 1, "cost": 15},
	"speed": {"level": 1, "cost": 20},
}

func upgrade_level(id: String) -> int:
	return upgrades[id]["level"]

func upgrade_cost(id: String) -> int:
	return upgrades[id]["cost"]

func is_maxed(id: String) -> bool:
	return upgrade_level(id) >= MAX_UPGRADE_LEVEL

func can_buy(id: String) -> bool:
	return not is_maxed(id) and coins >= upgrade_cost(id)

# Returns true if the purchase went through.
func buy_upgrade(id: String) -> bool:
	if is_maxed(id) or not spend_coins(upgrade_cost(id)):
		return false
	upgrades[id]["level"] += 1
	upgrades[id]["cost"] = int(upgrades[id]["cost"] * UPGRADE_COST_GROWTH)
	return true

# Effects, used by the player, the puzzle and the upgrades screen.
func fuel_bonus(level: int = -1) -> float:
	if level < 0:
		level = upgrade_level("booster")
	return (level - 1) * FUEL_PER_LEVEL

func speed_bonus(level: int = -1) -> float:
	if level < 0:
		level = upgrade_level("speed")
	return (level - 1) * SPEED_PER_LEVEL

func hints_per_puzzle(level: int = -1) -> int:
	if level < 0:
		level = upgrade_level("hints")
	return level - 1

func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)

func spend_coins(amount: int) -> bool:
	if coins < amount:
		return false
	coins -= amount
	coins_changed.emit(coins)
	return true

# Called by every level when it loads.
func register_level(path: String) -> void:
	var idx := LEVELS.find(path)
	if idx != -1:
		current_level = idx
	level_cleared = false

func current_level_path() -> String:
	return LEVELS[current_level]

func has_next_level() -> bool:
	return current_level < LEVELS.size() - 1

func next_level_path() -> String:
	return LEVELS[mini(current_level + 1, LEVELS.size() - 1)]

# Where "Back" from the upgrades screen should go.
func resume_level_path() -> String:
	if level_cleared and has_next_level():
		return next_level_path()
	return current_level_path()
