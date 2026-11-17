extends CharacterBody2D 

@export var speed: float = 150.0 

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D 

var last_direction: String = "down" 
var is_using_computer: bool = false
func _physics_process(_delta: float) -> void: 
	if is_using_computer:
		velocity = Vector2.ZERO
		move_and_slide()
		_play_idle()
		return
		
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") 
	velocity = direction * speed 
	move_and_slide() 
	update_animation(direction) 
	  	


func update_animation(direction: Vector2) -> void: 
	if direction == Vector2.ZERO: 
		_play_idle()
		return 

	if direction.x != 0 and direction.y != 0:
		if direction.x > 0:
			last_direction = "right"
			animated_sprite.flip_h = false
			animated_sprite.play("side_walk")
		else:
			last_direction = "left"
			animated_sprite.flip_h = true
			animated_sprite.play("side_walk")

	elif abs(direction.x) > abs(direction.y): 
		if direction.x > 0: 
			last_direction = "right" 
			animated_sprite.flip_h = false 
			animated_sprite.play("side_walk") 
		else: 
			last_direction = "left" 
			animated_sprite.flip_h = true 
			animated_sprite.play("side_walk") 
	else: 
		animated_sprite.flip_h = false
		if direction.y > 0: 
			last_direction = "down" 
			animated_sprite.play("front_walk") 
		else: 
			last_direction = "up" 
			animated_sprite.play("back_walk")

func _play_idle() -> void:
	match last_direction:
		"up":
			animated_sprite.flip_h = false
			animated_sprite.play("back_idle")
		"left", "right":
			animated_sprite.play("side_idle")
		_:
			animated_sprite.flip_h = false
			animated_sprite.play("idle")
