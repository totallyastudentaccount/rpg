class_name TimeSystem
extends Node

@export var tick_per_second: float = 60.0

var seconds: float = 0.0
var minutes: int = 0
var hours: int = 0
var days: int = 0

# Signal that passes hours and minutes
signal time_changed(hours: int, minutes: int)

func _process(delta: float) -> void:
	seconds += delta * tick_per_second
	
	if seconds >= 60.0:
		seconds = fmod(seconds, 60.0)
		minutes += 1
		
		if minutes >= 60:
			minutes = 0
			hours += 1
			
			if hours >= 24:
				hours = 0
				days += 1
				
		# Only emit the signal when a minute actually changes
		time_changed.emit(hours, minutes)
