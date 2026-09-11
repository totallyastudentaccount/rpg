extends Control

# This function runs automatically as soon as the main menu loads
func _ready() -> void:
	# This connects your button clicks directly to the functions below
	$VBoxContainer/play.pressed.connect(load_level_1)
	$VBoxContainer/option.pressed.connect(load_level_2)
	$VBoxContainer/quit.pressed.connect(load_credits)

func load_level_1() -> void:
	get_tree().change_scene_to_file("res://scene/main.tscn")

func load_level_2() -> void:
	get_tree().change_scene_to_file("res://scene/menus/main_menu/settings.tscn")

func load_credits() -> void:
	print("Exit button was clicked!")
	get_tree().quit()
