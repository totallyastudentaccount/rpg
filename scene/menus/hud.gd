extends CanvasLayer

# This grabs your text label automatically from your scene tree
@onready var time_label: Label = $Control/timeLabel

func _ready() -> void:
	# Make sure the name matches whatever you called your Autoload script
	# (e.g., TimeManager, TimeSystem, or time_manager)
	TimeManager.time_changed.connect(_on_time_changed)

func _on_time_changed(hours: int, minutes: int) -> void:
	# Updates your UI text automatically
	time_label.text = "%02d:%02d" % [hours, minutes]
