extends Node2D

var money: int = 0
var money_per_click: int = 1

@onready var money_label: Label = $CanvasLayer/MoneyLabel

func _unhandled_input(event: InputEvent) -> void:
	# Check if the input event is a left mouse button click down
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		money += money_per_click
		update_ui()

func update_ui() -> void:
	if money_label:
		money_label.text = "Money: $" + str(money)
