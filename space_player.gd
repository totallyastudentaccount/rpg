# Player.gd (astronaut)
extends CharacterBody2D

signal fell_off_world

# --- Top-Down Movement Parameters ---
@export var base_max_speed: float = 200.0
@export var acceleration: float = 1200.0
@export var friction: float = 800.0

# --- Rocket Thruster & Gravity Parameters ---
@export var base_max_fuel: float = 2.0
@export var boost_accel: float = -900.0
@export var rising_gravity: float = 600.0
@export var base_falling_gravity: float = 1800.0
@export var max_fall_speed: float = 800.0
@export var fall_limit_y: float = 1000.0 # Y position that counts as "fell off the world"

# Effective stats modified by upgrades
var max_speed: float
var max_fuel: float
var falling_gravity: float

var current_fuel: float
var is_boosting: bool = false

# Set to false while a puzzle is open so typing doesn't move the astronaut.
var controls_enabled: bool = true
var _has_fallen: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("Player")
	apply_upgrades()

func apply_upgrades() -> void:
	max_fuel = base_max_fuel + ((GameData.booster_level - 1) * 0.75)
	current_fuel = max_fuel
	max_speed = base_max_speed + ((GameData.teleport_level - 1) * 25.0)
	falling_gravity = max(600.0, base_falling_gravity - ((GameData.hint_level - 1) * 150.0))

func _physics_process(delta: float) -> void:
	handle_smooth_movement(delta)
	handle_rocket_thrust(delta)
	update_animations()
	move_and_slide()

	if not _has_fallen and global_position.y > fall_limit_y:
		_has_fallen = true
		fell_off_world.emit()

func handle_smooth_movement(delta: float) -> void:
	var input_vector := Vector2.ZERO
	if controls_enabled:
		input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if input_vector != Vector2.ZERO:
		velocity.x = move_toward(velocity.x, input_vector.x * max_speed, acceleration * delta)
		if is_on_floor() or not is_boosting:
			velocity.y = move_toward(velocity.y, input_vector.y * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		if is_on_floor():
			velocity.y = move_toward(velocity.y, 0.0, friction * delta)

func handle_rocket_thrust(delta: float) -> void:
	if controls_enabled and Input.is_action_pressed("ui_accept") and current_fuel > 0:
		is_boosting = true
		current_fuel -= delta
		velocity.y += boost_accel * delta
	else:
		is_boosting = false

	if not is_on_floor():
		if velocity.y > 0:
			velocity.y += falling_gravity * delta
		else:
			velocity.y += rising_gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)
	else:
		current_fuel = move_toward(current_fuel, max_fuel, delta * 3.0)

func update_animations() -> void:
	if sprite == null:
		return

	if velocity.length() > 10.0 or is_boosting:
		if sprite.sprite_frames.has_animation("floating"):
			sprite.play("floating")
		if velocity.x != 0:
			sprite.flip_h = velocity.x < 0
	else:
		if sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")
