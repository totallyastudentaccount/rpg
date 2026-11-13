# Shared by LevelWon.tscn (is_win = true) and LevelLost.tscn.
extends Control

const UPGRADES_SCENE := "res://scene/computer/apps/spaceRPG/Upgrades.tscn"

@export var is_win: bool = false

@onready var title_label: Label = $Label
@onready var main_button: Button = $HBoxContainer/Button

func _ready() -> void:
	if is_win:
		if GameData.has_next_level():
			main_button.text = "NEXT LEVEL"
		else:
			title_label.text = "You beat all levels!"
			main_button.text = "PLAY AGAIN"
	else:
		main_button.text = "RESTART"

func _on_next_level_button_pressed() -> void:
	var path: String
	if is_win:
		path = GameData.next_level_path() if GameData.has_next_level() else GameData.LEVELS[0]
	else:
		path = GameData.current_level_path()
	_go_to(path)

func _on_upgrade_button_pressed() -> void:
	_go_to(UPGRADES_SCENE)

func _on_quit_button_pressed() -> void:
	var desktop = get_tree().get_first_node_in_group("DesktopUI")
	if desktop:
		desktop.close_current_app()
	else:
		get_tree().quit()

func _go_to(path: String) -> void:
	var desktop = get_tree().get_first_node_in_group("DesktopUI")
	if desktop:
		desktop.change_subviewport_scene(path)
	else:
		get_tree().change_scene_to_file(path)
