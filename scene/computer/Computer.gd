extends Area2D

# Preload the exact path to your desktop UI scene
const DESKTOP_UI_SCENE = preload("res://scene/computer/DesktopUI.tscn") 

var player_in_range: bool = false

# Access your text prompt child node
@onready var prompt = $InteractionPrompt

func _ready():
	# Hide the "Press E to interact" text when the game starts
	prompt.visible = false
	
	# Connect the Area2D signals to detect when objects walk inside
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta):
	# Check if player is close by AND presses your interact action ("E")
	if player_in_range and Input.is_action_just_pressed("interact"):
		open_desktop()

func _on_body_entered(body):
	# Checks if the object entering is the player node or part of the Player group
	if body.name == "player" or body.is_in_group("Player"):
		player_in_range = true
		prompt.visible = true

func _on_body_exited(body):
	# Turn off interaction flags when the player walks away
	if body.name == "player" or body.is_in_group("Player"):
		player_in_range = false
		prompt.visible = false

func open_desktop():
	# Spawn a clone of your DesktopUI layout
	var desktop_instance = DESKTOP_UI_SCENE.instantiate()
	
	# Add it to the tree root so it displays directly on top of your game window
	get_tree().root.add_child(desktop_instance)
