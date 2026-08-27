extends Area2D

# Allows you to choose the target file directly from the Inspector
@export_file("*.tscn") var target_scene: String

func _on_body_entered(body: Node2D) -> void:
	# Replace 'Player' with the exact name or class of your player node
	if body.name == "player": 
		if target_scene != "":
			get_tree().call_deferred("change_scene_to_file", target_scene)
		else:
			print("Warning: No target scene assigned to this door!")
