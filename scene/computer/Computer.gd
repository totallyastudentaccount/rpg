extends Area2D

const DESKTOP_UI_SCENE = preload("res://scene/computer/DesktopUI.tscn")

var player_in_range: bool = false
var active_desktop: Node = null  # Track if DesktopUI is currently open

@onready var prompt = $InteractionPrompt
@export var installed_apps: Array[AppData] = []

func _ready() -> void:
	prompt.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	# Only allow opening the desktop if it is NOT already open!
	if player_in_range and active_desktop == null and Input.is_action_just_pressed("interact"):
		open_desktop()
		
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "player":
		player_in_range = true
		prompt.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "player":
		player_in_range = false
		prompt.visible = false

func open_desktop() -> void:
	# 1. Disable player movement/input
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if "is_using_computer" in player:
			player.is_using_computer = true
		else:
			player.set_physics_process(false)
			player.set_process_unhandled_input(false)

	# 2. Instantiate DesktopUI and store reference
	active_desktop = DESKTOP_UI_SCENE.instantiate()
	get_tree().root.add_child(active_desktop)
	
	if active_desktop.has_method("setup_desktop"):
		active_desktop.setup_desktop(installed_apps, true)

	# 3. Clean up references when DesktopUI closes
	active_desktop.tree_exited.connect(func():
		active_desktop = null  # Reset reference so 'E' can open it again later
		
		if is_instance_valid(player):
			if "is_using_computer" in player:
				player.is_using_computer = false
			else:
				player.set_physics_process(true)
				player.set_process_unhandled_input(true)
	)
