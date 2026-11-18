# Anagram.gd
extends Control

signal puzzle_solved(box: Area2D)
signal puzzle_cancelled

const GOOD := Color(0.1, 0.55, 0.15)
const BAD := Color(0.8, 0.1, 0.1)
const NEUTRAL := Color(0.15, 0.15, 0.15)
const SOLVED_DELAY: float = 0.8

@onready var panel: VBoxContainer = $VBoxContainer
@onready var clue_label: Label = $VBoxContainer/Label
@onready var input_field: LineEdit = $VBoxContainer/LineEdit
@onready var feedback_label: Label = $VBoxContainer/FeedbackLabel
@onready var hint_button: Button = $VBoxContainer/HintButton

var current_target_word: String = ""
var _scrambled: String = ""
var current_box: Area2D = null

var _wrong_guesses: int = 0
var _resolved: bool = false # true once solved, so a second Enter can't double-submit
var _base_pos: Vector2
var _shake_tween: Tween

func start_puzzle(scrambled: String, answer: String, box: Area2D) -> void:
	current_target_word = answer.strip_edges().to_upper()
	current_box = box

	_scrambled = scrambled.to_upper()
	clue_label.text = "Unscramble: " + _scrambled
	clue_label.add_theme_color_override("font_color", Color.BLACK)

	input_field.text = ""
	input_field.placeholder_text = "Enter guess"
	input_field.add_theme_color_override("font_color", Color.WHITE)
	input_field.add_theme_color_override("font_placeholder_color", Color(0.8, 0.8, 0.8))

	_set_feedback("", NEUTRAL)
	_refresh_hint_ui()

	show()

	await get_tree().process_frame
	if is_instance_valid(input_field):
		_base_pos = panel.position
		input_field.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if not _resolved:
			_cancel()

func _on_button_pressed() -> void:
	_check_answer()

func _on_line_edit_text_submitted(_new_text: String) -> void:
	_check_answer()

func _on_cancel_pressed() -> void:
	if not _resolved:
		_cancel()

func _cancel() -> void:
	puzzle_cancelled.emit()
	queue_free()

# ---------------------------------------------------------------- answers

func _check_answer() -> void:
	if _resolved:
		return
	var user_guess := input_field.text.strip_edges().to_upper()
	if user_guess.is_empty():
		_wrong("Type your guess first!", false)
	elif user_guess == current_target_word:
		_correct()
	else:
		_wrong("Not quite - try again!" if _wrong_guesses < 2 else "Still wrong. Look at the letters again!", true)

func _correct() -> void:
	_resolved = true
	input_field.editable = false
	hint_button.disabled = true
	input_field.add_theme_color_override("font_color", GOOD)
	_set_feedback("Correct! +%d coins" % GameData.COINS_PER_PUZZLE, GOOD)

	# Pop the whole panel so the win feels good.
	panel.pivot_offset = panel.size / 2.0
	var pop := create_tween()
	pop.tween_property(panel, "scale", Vector2(1.08, 1.08), 0.12)
	pop.tween_property(panel, "scale", Vector2.ONE, 0.12)

	# Give the player a moment to see the message before the puzzle closes.
	await get_tree().create_timer(SOLVED_DELAY).timeout
	if is_instance_valid(current_box):
		current_box.activate()
	puzzle_solved.emit(current_box)
	queue_free()

func _wrong(message: String, counts_as_guess: bool) -> void:
	if counts_as_guess:
		_wrong_guesses += 1
	_set_feedback(message, BAD)
	_shake()

	# Flash the text red, then back to normal. Keep the guess so it can be tweaked.
	input_field.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
	input_field.select_all()
	input_field.grab_focus()
	var flash := create_tween()
	flash.tween_interval(0.35)
	flash.tween_callback(func():
		if is_instance_valid(input_field):
			input_field.add_theme_color_override("font_color", Color.WHITE))

func _shake() -> void:
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
	panel.position = _base_pos
	_shake_tween = create_tween()
	for offset in [-12.0, 12.0, -8.0, 8.0, -4.0, 4.0, 0.0]:
		_shake_tween.tween_property(panel, "position:x", _base_pos.x + offset, 0.04)

func _set_feedback(message: String, color: Color) -> void:
	feedback_label.text = message
	feedback_label.add_theme_color_override("font_color", color)

# ---------------------------------------------------------------- hints

# Hints used are remembered on the box, so closing and reopening
# the puzzle doesn't hand out free hints.
func _hints_used() -> int:
	if is_instance_valid(current_box):
		return current_box.get_meta("hints_used", 0)
	return 0

func _hints_allowed() -> int:
	return mini(GameData.hints_per_puzzle(), current_target_word.length() - 1)

func _on_hint_pressed() -> void:
	if _resolved or _hints_used() >= _hints_allowed():
		return
	if is_instance_valid(current_box):
		current_box.set_meta("hints_used", _hints_used() + 1)
	_refresh_hint_ui()
	input_field.grab_focus()

func _refresh_hint_ui() -> void:
	var allowed := _hints_allowed()
	var used := _hints_used()

	clue_label.text = "Unscramble: " + _scrambled
	if used > 0:
		clue_label.text += "\nHint: " + _reveal_text(used)

	if allowed <= 0:
		hint_button.text = "Hints locked (buy Puzzle Hints upgrade)"
		hint_button.disabled = true
	elif used >= allowed:
		hint_button.text = "No hints left"
		hint_button.disabled = true
	else:
		hint_button.text = "Hint (%d left)" % (allowed - used)
		hint_button.disabled = false

# "ROCKET" with 2 letters revealed -> "R O _ _ _ _"
func _reveal_text(count: int) -> String:
	var parts: PackedStringArray = []
	for i in current_target_word.length():
		parts.append(current_target_word[i] if i < count else "_")
	return " ".join(parts)
