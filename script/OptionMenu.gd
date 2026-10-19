extends Control

# This function runs automatically as soon as the main menu loads
func _ready() -> void:
	# This connects your button clicks directly to the functions below
	$HBoxContainer2/Button.pressed.connect(load_level_1)
	$HBoxContainer2/Button2.pressed.connect(load_level_2)
	$HBoxContainer2/Button3.pressed.connect(load_credits)
	$HBoxContainer2/Button4.pressed.connect(load_level_3)
	$HBoxContainer2/Button5.pressed.connect(load_level_4)

func load_level_1() -> void:
	get_tree().change_scene_to_file("res://scene/menus/main_menu/settings.tscn")

func load_level_2() -> void:
	get_tree().change_scene_to_file("res://scene/menus/main_menu/save.tscn")

func load_credits() -> void:
	get_tree().change_scene_to_file("res://scene/menus/main_menu/mainmenu.tscn")
	
func load_level_3() -> void:
	get_tree().change_scene_to_file("res://scene/menus/main_menu/control.tscn")

func load_level_4() -> void:
	get_tree().change_scene_to_file("res://scene/menus/main_menu/credit.tscn")
