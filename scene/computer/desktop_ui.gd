extends Window

@onready var icon_grid: GridContainer = $MarginContainer/IconGrid
@onready var app_container: SubViewportContainer = $AppContainer
@onready var app_viewport: SubViewport = $AppContainer/AppViewport
@onready var active_app_label: Label = $TaskBar/HBoxContainer/ActiveAppLabel
@onready var fullscreen_button: Button = $TaskBar/HBoxContainer/FullscreenButton

const APP_BUTTON_SCENE = preload("res://scene/computer/appButtonUI.tscn")
var is_in_office: bool = false
var active_app_instance: Node = null

# Desktop base window dimensions
var mini_size: Vector2i = Vector2i(1152, 648)

func _ready() -> void:
	add_to_group("DesktopUI") # Allows GameManager/LevelWon/LevelLost to find this window easily
	close_requested.connect(func(): queue_free())
	app_container.visible = false
	
	if fullscreen_button:
		fullscreen_button.pressed.connect(toggle_fullscreen)

func setup_desktop(available_apps: Array[AppData], in_office: bool) -> void:
	is_in_office = in_office
	
	for child in icon_grid.get_children():
		child.queue_free()
		
	for app in available_apps:
		if app.is_office_only and not is_in_office:
			continue
		create_desktop_icon(app)
		
	$AppContainer.focus_mode = Control.FOCUS_ALL

func create_desktop_icon(app: AppData) -> void:
	var btn = APP_BUTTON_SCENE.instantiate() as TextureButton
	
	if btn:
		if app.icon:
			btn.texture_normal = app.icon
			
		if btn.has_node("Label"):
			btn.get_node("Label").text = app.app_name

		btn.pressed.connect(func(): launch_app(app))
		icon_grid.add_child(btn)

func launch_app(app: AppData) -> void:
	if not app or not app.app_scene:
		print("ERROR: app_scene is missing from AppData!")
		return

	close_current_app()

	var app_instance = app.app_scene.instantiate()
	app_viewport.add_child(app_instance)
	active_app_instance = app_instance
	
	app_container.visible = true
	
	if active_app_label:
		active_app_label.text = "Running: " + app.app_name

# SWAP SCENES INSIDE SUBVIEWPORT WITHOUT BREAKING DESKTOP UI
func change_subviewport_scene(scene_path: String) -> void:
	close_current_app()
	
	var new_scene_res = load(scene_path)
	if new_scene_res:
		var new_instance = new_scene_res.instantiate()
		app_viewport.add_child(new_instance)
		active_app_instance = new_instance
		app_container.visible = true
	else:
		print("ERROR: Could not load scene at ", scene_path)

func close_current_app() -> void:
	if is_instance_valid(active_app_instance):
		active_app_instance.queue_free()
		active_app_instance = null
		
	app_container.visible = false
	
	if active_app_label:
		active_app_label.text = ""

func toggle_fullscreen() -> void:
	if mode == Window.MODE_EXCLUSIVE_FULLSCREEN or mode == Window.MODE_FULLSCREEN:
		mode = Window.MODE_WINDOWED
		size = mini_size
		fullscreen_button.text = "[ Fullscreen ]"
	else:
		mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		fullscreen_button.text = "[ Windowed ]"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if is_instance_valid(active_app_instance):
			close_current_app()
		else:
			queue_free()
		get_viewport().set_input_as_handled()
