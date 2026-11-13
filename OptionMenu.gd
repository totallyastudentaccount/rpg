extends Control

func _ready() -> void:
	$HBoxContainer2/Button.pressed.connect(open_settings)
	$HBoxContainer2/Button2.pressed.connect(open_saves)
	$HBoxContainer2/Button3.pressed.connect(back_to_main_menu)
	$HBoxContainer2/Button4.pressed.connect(open_controls)
	$HBoxContainer2/Button5.pressed.connect(open_credits)

func open_settings() -> void:
	get_tree().change_scene_to_file("res://scene/menus/main_menu/settings.tscn")

func open_saves() -> void:
	get_tree().change_scene_to_file("res://scene/menus/main_menu/save.tscn")

func back_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://scene/menus/main_menu/mainmenu.tscn")

func open_controls() -> void:
	get_tree().change_scene_to_file("res://scene/menus/main_menu/control.tscn")

func open_credits() -> void:
	get_tree().change_scene_to_file("res://scene/menus/main_menu/credit.tscn")
