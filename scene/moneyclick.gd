extends Control

# Variables to track money and earnings per click
var money: int = 0
var money_per_click: int = 1

# Reference to a Label node to display the money count
@onready var money_label: Label = $MoneyLabel

func _ready() -> void:
	update_ui()

# Call this function whenever the player clicks the main button
func _on_click_button_pressed() -> void:
	money += money_per_click
	update_ui()

# Updates the visual UI text
func update_ui() -> void:
	if money_label:
		money_label.text = "Money: $" + str(money)
