# Anagram.gd
extends Control

signal puzzle_solved(box: Area2D)
signal puzzle_cancelled

@onready var clue_label: Label = $VBoxContainer/Label
@onready var input_field: LineEdit = $VBoxContainer/LineEdit

var current_target_word: String = ""
var current_box: Area2D = null

func start_puzzle(scrambled: String, answer: String, box: Area2D) -> void:
	current_target_word = answer.strip_edges().to_upper()
	current_box = box

	clue_label.text = "Unscramble: " + scrambled.to_upper()
	clue_label.add_theme_color_override("font_color", Color.BLACK)

	input_field.text = ""
	input_field.placeholder_text = "Enter guess"
	input_field.add_theme_color_override("font_color", Color.WHITE)
	input_field.add_theme_color_override("font_placeholder_color", Color(0.8, 0.8, 0.8))

	show()

	await get_tree().process_frame
	if is_instance_valid(input_field):
		input_field.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_cancel()

func _on_button_pressed() -> void:
	_check_answer()

func _on_line_edit_text_submitted(_new_text: String) -> void:
	_check_answer()

func _on_cancel_pressed() -> void:
	_cancel()

func _cancel() -> void:
	puzzle_cancelled.emit()
	queue_free()

func _check_answer() -> void:
	var user_guess := input_field.text.strip_edges().to_upper()

	if user_guess == current_target_word:
		if is_instance_valid(current_box):
			current_box.activate()
		puzzle_solved.emit(current_box)
		queue_free()
	else:
		input_field.text = ""
		input_field.placeholder_text = "Incorrect! Try again..."
		input_field.grab_focus()
