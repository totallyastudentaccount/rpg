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

var coins: int = 0

# Progress through LEVELS
var current_level: int = 0
var level_cleared: bool = false

# Upgrade Levels & Costs
var booster_level: int = 1
var booster_cost: int = 10

var hint_level: int = 1
var hint_cost: int = 15

var teleport_level: int = 1
var teleport_cost: int = 20

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
