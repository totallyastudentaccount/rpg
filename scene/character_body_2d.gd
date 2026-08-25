extends CharacterBody2D

@export var speed: float = 100.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Tracks the last directional facing state for idle animations
var last_direction: String = "down"

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	velocity = direction * speed
	move_and_slide()
	
	update_animation(direction)

func update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		animated_sprite.play("idle")
		return
		
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			last_direction = "right"
			animated_sprite.flip_h = false
			animated_sprite.play("side_walk")
		else:
			last_direction = "left"
			animated_sprite.flip_h = true
			animated_sprite.play("side_walk")
	else:
		if direction.y > 0:
			last_direction = "down"
			animated_sprite.play("front_walk")
		else:
			last_direction = "up"
			animated_sprite.play("back_walk")
	
	
