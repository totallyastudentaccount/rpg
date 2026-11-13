extends Node

signal minute_passed(hour: int, minute: int)

@export var real_seconds_per_game_minute: float = 0.5
@export var start_hour: int = 8
@export var start_minute: int = 0

var current_hour: int = 8
var current_minute: int = 0
var minute_timer: float = 0.0

func _ready() -> void:
	current_hour = start_hour
	current_minute = start_minute

func reset() -> void:
	current_hour = start_hour
	current_minute = start_minute
	minute_timer = 0.0

func _process(delta: float) -> void:
	minute_timer += delta
	if minute_timer >= real_seconds_per_game_minute:
		minute_timer -= real_seconds_per_game_minute
		advance_minute()

func advance_minute() -> void:
	current_minute += 1
	if current_minute >= 60:
		current_minute = 0
		current_hour += 1
		if current_hour >= 24:
			current_hour = 0
			
	minute_passed.emit(current_hour, current_minute)

func get_formatted_time() -> String:
	var display_hour = current_hour % 12
	if display_hour == 0:
		display_hour = 12
	var period = "AM" if current_hour < 12 else "PM"
	return "%02d:%02d %s" % [display_hour, current_minute, period]
