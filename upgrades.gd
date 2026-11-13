# Upgrades.gd
extends Control

@onready var coins_label: Label = $Label
@onready var vbox1: VBoxContainer = $ColorRect/HBoxContainer/VBoxContainer
@onready var vbox2: VBoxContainer = $ColorRect/HBoxContainer/VBoxContainer2
@onready var vbox3: VBoxContainer = $ColorRect/HBoxContainer/VBoxContainer3

func _ready() -> void:
	vbox1.get_node("BuyButton").pressed.connect(_on_booster_buy_pressed)
	vbox2.get_node("BuyButton").pressed.connect(_on_hint_buy_pressed)
	vbox3.get_node("BuyButton").pressed.connect(_on_teleport_buy_pressed)
	$BackButton.pressed.connect(_on_back_pressed)
	update_ui()

func update_ui() -> void:
	coins_label.text = "Coins: " + str(GameData.coins)
	_fill(vbox1, "Booster", GameData.booster_level, GameData.booster_cost)
	_fill(vbox2, "Hint Upgrade", GameData.hint_level, GameData.hint_cost)
	_fill(vbox3, "Teleport", GameData.teleport_level, GameData.teleport_cost)

func _fill(box: VBoxContainer, title: String, level: int, cost: int) -> void:
	box.get_node("Label").text = "%s (Lvl %d)" % [title, level]
	box.get_node("Label2").text = "Cost: %d Coins" % cost
	box.get_node("BuyButton").disabled = GameData.coins < cost

func _on_booster_buy_pressed() -> void:
	if GameData.spend_coins(GameData.booster_cost):
		GameData.booster_level += 1
		GameData.booster_cost = int(GameData.booster_cost * GameData.UPGRADE_COST_GROWTH)
		update_ui()

func _on_hint_buy_pressed() -> void:
	if GameData.spend_coins(GameData.hint_cost):
		GameData.hint_level += 1
		GameData.hint_cost = int(GameData.hint_cost * GameData.UPGRADE_COST_GROWTH)
		update_ui()

func _on_teleport_buy_pressed() -> void:
	if GameData.spend_coins(GameData.teleport_cost):
		GameData.teleport_level += 1
		GameData.teleport_cost = int(GameData.teleport_cost * GameData.UPGRADE_COST_GROWTH)
		update_ui()

func _on_back_pressed() -> void:
	var path := GameData.resume_level_path()
	var desktop = get_tree().get_first_node_in_group("DesktopUI")
	if desktop:
		desktop.change_subviewport_scene(path)
	else:
		get_tree().change_scene_to_file(path)
