# GameData.gd
extends Node

var coins: int = 0

# Upgrade Levels & Multipliers
var booster_level: int = 1
var booster_cost: int = 10

var hint_level: int = 1
var hint_cost: int = 15

var teleport_level: int = 1
var teleport_cost: int = 20

func add_coins(amount: int) -> void:
	coins += amount
	print("Coins collected! Total: ", coins)
