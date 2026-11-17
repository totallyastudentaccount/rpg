extends Button
## Drop onto any Button: clicking it returns to the options menu.

@export_file("*.tscn") var target_scene: String = "res://scene/menus/main_menu/settings.tscn"

func _ready() -> void:
	pressed.connect(func(): get_tree().change_scene_to_file(target_scene))
