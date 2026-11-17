extends Control

@onready var clock_label: Label = $ClockLabel
@onready var mood_container: VBoxContainer = $VBoxContainer

func _ready() -> void:
	# Connect directly to the global Autoload instance
	TimeManager.minute_passed.connect(_on_minute_passed)
	clock_label.text = TimeManager.get_formatted_time()

func _on_minute_passed(_hour: int, _minute: int) -> void:
	clock_label.text = TimeManager.get_formatted_time()
	
	for child in mood_container.get_children():
		if child is MoodBar:
			child.apply_decay()
