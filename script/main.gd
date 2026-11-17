extends Control

func _ready() -> void:
	$VBoxContainer/play.pressed.connect(start_game)
	$VBoxContainer/option.pressed.connect(open_options)
	$VBoxContainer/quit.pressed.connect(quit_game)

func start_game() -> void:
	TimeManager.reset() # TimeManager is an autoload, so restart the clock for a new game
	get_tree().change_scene_to_file("res://scene/main.tscn")

func open_options() -> void:
	get_tree().change_scene_to_file("res://scene/menus/main_menu/settings.tscn")

func quit_game() -> void:
	get_tree().quit()
