class_name MoodBar
extends ProgressBar

@export var max_mood: float = 100.0
@export var decay_per_minute: float = 0.5 # Change this in each bar's Inspector!

var current_mood: float = 100.0

func _ready() -> void:
	max_value = max_mood
	current_mood = max_mood
	value = current_mood
	_update_color()

func apply_decay() -> void:
	change_mood(decay_per_minute)

func change_mood(amount: float) -> void:
	current_mood = clamp(current_mood - amount, 0.0, max_mood)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "value", current_mood, 0.3)
	
	var ratio = current_mood / max_mood
	var target_color = Color.RED.lerp(Color.GREEN, ratio)
	tween.tween_property(self, "modulate", target_color, 0.3)

func _update_color() -> void:
	var ratio = current_mood / max_mood
	modulate = Color.RED.lerp(Color.GREEN, ratio)
