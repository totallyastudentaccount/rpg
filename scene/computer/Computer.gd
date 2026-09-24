extends Area2D

@export var desktop_scene: PackedScene 
@export var installed_apps: Array[AppData] = []
@export var is_office_computer: bool = false 

@onready var interaction_prompt: Label = $InteractionPrompt

var player_in_range: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if interaction_prompt:
		interaction_prompt.visible = false

func _on_body_entered(body: Node2D) -> void:
	print("Something entered area: ", body.name)
	print("Is body in 'Player' group? ", body.is_in_group("player"))
	if body.is_in_group("Player"):
		player_in_range = true
		if interaction_prompt:
			interaction_prompt.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if interaction_prompt:
			interaction_prompt.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		print("Interact pressed! Player in range? ", player_in_range)
		if player_in_range:
			open_computer()

func open_computer() -> void:
	print("open_computer() called. Desktop scene assigned? ", desktop_scene != null)
	if get_tree().root.has_node("ActiveDesktop"):
		print("ActiveDesktop already exists!")
		return
		
	if desktop_scene:
		var desktop = desktop_scene.instantiate()
		desktop.name = "ActiveDesktop"
		get_tree().root.add_child(desktop)
		print("Desktop spawned successfully!")
		desktop.setup_desktop(installed_apps, is_office_computer)
