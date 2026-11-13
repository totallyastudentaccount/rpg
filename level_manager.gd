extends Node2D
## Shared controller for every Space RPG level (replaces the three copies
## that used to be embedded in the level scenes).

const ANAGRAM_SCENE: PackedScene = preload("res://scene/computer/apps/spaceRPG/Anagram.tscn")
const LEVEL_WON_SCENE := "res://scene/computer/apps/spaceRPG/LevelWon.tscn"
const LEVEL_LOST_SCENE := "res://scene/computer/apps/spaceRPG/LevelLost.tscn"

var total_fuel_boxes: int = 0
var activated_boxes_count: int = 0

var _puzzle_open: bool = false
var _finished: bool = false
var _player: Node = null

@onready var canvas_layer: CanvasLayer = $CanvasLayer

func _ready() -> void:
	GameData.register_level(scene_file_path)

	_player = _find_player()
	if _player and _player.has_signal("fell_off_world"):
		_player.fell_off_world.connect(game_lost)

	# Only boxes that belong to THIS level (the old level may still be
	# in the group for a frame after a scene swap).
	for box in get_tree().get_nodes_in_group("FuelBoxes"):
		if not is_ancestor_of(box):
			continue
		if box.has_signal("open_puzzle"):
			total_fuel_boxes += 1
			if not box.open_puzzle.is_connected(_on_open_puzzle):
				box.open_puzzle.connect(_on_open_puzzle)
		else:
			push_warning("Node in FuelBoxes group missing open_puzzle signal: " + str(box.name))

func _find_player() -> Node:
	# The house world also has a node in group "Player", so only accept ours.
	for node in get_tree().get_nodes_in_group("Player"):
		if is_ancestor_of(node):
			return node
	return null

func _set_player_controls(enabled: bool) -> void:
	if is_instance_valid(_player) and "controls_enabled" in _player:
		_player.controls_enabled = enabled

func _on_open_puzzle(scrambled: String, answer: String, box: Area2D) -> void:
	if _puzzle_open or _finished:
		return
	_puzzle_open = true
	_set_player_controls(false) # stop WASD/Space from moving the astronaut while typing

	var puzzle = ANAGRAM_SCENE.instantiate()
	canvas_layer.add_child(puzzle)
	puzzle.puzzle_solved.connect(_on_puzzle_solved)
	puzzle.puzzle_cancelled.connect(_on_puzzle_cancelled)
	puzzle.start_puzzle(scrambled, answer, box)

func _on_puzzle_solved(_box: Area2D) -> void:
	_puzzle_open = false
	_set_player_controls(true)
	GameData.add_coins(GameData.COINS_PER_PUZZLE)
	activated_boxes_count += 1
	if total_fuel_boxes > 0 and activated_boxes_count >= total_fuel_boxes:
		game_win()

func _on_puzzle_cancelled() -> void:
	_puzzle_open = false
	_set_player_controls(true)

func game_win() -> void:
	if _finished:
		return
	_finished = true
	GameData.level_cleared = true
	GameData.add_coins(GameData.COINS_PER_LEVEL)
	_change_screen(LEVEL_WON_SCENE)

func game_lost() -> void:
	if _finished:
		return
	_finished = true
	_change_screen(LEVEL_LOST_SCENE)

func _change_screen(path: String) -> void:
	var desktop = get_tree().get_first_node_in_group("DesktopUI")
	if desktop:
		desktop.change_subviewport_scene(path)
	else:
		get_tree().change_scene_to_file(path)
