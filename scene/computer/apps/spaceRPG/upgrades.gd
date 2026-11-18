# Upgrades.gd
extends Control

## Each column on the screen is one upgrade. `id` matches GameData.upgrades.
const COLUMNS := [
	{"id": "booster", "title": "Booster Fuel", "box": "ColorRect/HBoxContainer/VBoxContainer"},
	{"id": "hints", "title": "Puzzle Hints", "box": "ColorRect/HBoxContainer/VBoxContainer2"},
	{"id": "speed", "title": "Engine Speed", "box": "ColorRect/HBoxContainer/VBoxContainer3"},
]

const GOOD := Color(0.1, 0.55, 0.15)
const NORMAL := Color.BLACK

@onready var coins_label: Label = $Label

func _ready() -> void:
	for col in COLUMNS:
		var id: String = col["id"]
		get_node(col["box"]).get_node("BuyButton").pressed.connect(_on_buy_pressed.bind(id))
	$BackButton.pressed.connect(_on_back_pressed)
	update_ui()

func update_ui() -> void:
	coins_label.text = "Coins: " + str(GameData.coins)
	for col in COLUMNS:
		_fill(get_node(col["box"]), col["id"], col["title"])

func _fill(box: VBoxContainer, id: String, title: String) -> void:
	var level: int = GameData.upgrade_level(id)
	box.get_node("Label").text = "%s (Lvl %d/%d)" % [title, level, GameData.MAX_UPGRADE_LEVEL]

	var button: Button = box.get_node("BuyButton")
	var info: Label = box.get_node("Label2")
	if GameData.is_maxed(id):
		info.text = "%s\nMAX LEVEL" % _effect_text(id, level, -1)
		button.text = "Maxed"
		button.disabled = true
	else:
		var cost: int = GameData.upgrade_cost(id)
		info.text = "%s\nCost: %d coins" % [_effect_text(id, level, level + 1), cost]
		if GameData.coins >= cost:
			button.text = "Buy"
			button.disabled = false
		else:
			button.text = "Need %d more" % (cost - GameData.coins)
			button.disabled = true

# Shows what you have now and what the next level gives, e.g. "+0.75s -> +1.50s".
func _effect_text(id: String, level: int, next_level: int) -> String:
	match id:
		"booster":
			var now := "+%.2fs fuel" % GameData.fuel_bonus(level)
			return now if next_level < 0 else "%s -> +%.2fs" % [now, GameData.fuel_bonus(next_level)]
		"hints":
			var now := "%d hint(s) per puzzle" % GameData.hints_per_puzzle(level)
			return now if next_level < 0 else "%s -> %d" % [now, GameData.hints_per_puzzle(next_level)]
		"speed":
			var now := "+%d speed" % int(GameData.speed_bonus(level))
			return now if next_level < 0 else "%s -> +%d" % [now, int(GameData.speed_bonus(next_level))]
	return ""

func _on_buy_pressed(id: String) -> void:
	if not GameData.buy_upgrade(id):
		return
	update_ui()
	_celebrate(id)

# Little "pop" + green flash on the column you just upgraded.
func _celebrate(id: String) -> void:
	for col in COLUMNS:
		if col["id"] != id:
			continue
		var box: VBoxContainer = get_node(col["box"])
		var title: Label = box.get_node("Label")
		title.add_theme_color_override("font_color", GOOD)
		box.pivot_offset = box.size / 2.0
		box.scale = Vector2(1.12, 1.12)
		var tween := create_tween().set_parallel(true)
		tween.tween_property(box, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_callback(func(): title.add_theme_color_override("font_color", NORMAL)).set_delay(0.6)

func _on_back_pressed() -> void:
	var path := GameData.resume_level_path()
	var desktop = get_tree().get_first_node_in_group("DesktopUI")
	if desktop:
		desktop.change_subviewport_scene(path)
	else:
		get_tree().change_scene_to_file(path)
