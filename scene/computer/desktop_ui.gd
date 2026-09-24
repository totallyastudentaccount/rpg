extends Control

@onready var icon_grid: GridContainer = $IconGrid
@onready var app_container: Control = $AppContainer
@onready var active_app_label: Label = $TaskBar/HBoxContainer/ActiveAppLabel

var is_in_office: bool = false
var active_app_instance: Node = null

# Called by Computer.gd when opened
func setup_desktop(available_apps: Array[AppData], in_office: bool) -> void:
	is_in_office = in_office
	
	# Clear previous icons
	for child in icon_grid.get_children():
		child.queue_free()
		
	# Populate desktop icons
	for app in available_apps:
		if app.is_office_only and not is_in_office:
			continue
			
		create_desktop_icon(app)

func create_desktop_icon(app: AppData) -> void:
	var btn = Button.new()
	btn.text = app.app_name
	btn.custom_minimum_size = Vector2(80, 80)
	
	# Connect click event to launch the app
	btn.pressed.connect(func(): launch_app(app))
	
	icon_grid.add_child(btn)

func launch_app(app: AppData) -> void:
	# Close current open app if any
	close_current_app()
	
	if app.app_scene:
		# Create a window wrapper for the app UI
		var window_frame = PanelContainer.new()
		window_frame.name = "WindowFrame"
		window_frame.custom_minimum_size = Vector2(600, 400)
		
		# Center the window on screen
		window_frame.anchors_preset = Control.PRESET_CENTER
		
		# Instantiate the app inside the window frame
		var app_content = app.app_scene.instantiate()
		window_frame.add_child(app_content)
		
		app_container.add_child(window_frame)
		active_app_instance = window_frame
		
		# Update taskbar display
		active_app_label.text = "Running: " + app.app_name

func close_current_app() -> void:
	if is_instance_valid(active_app_instance):
		active_app_instance.queue_free()
		active_app_instance = null
		active_app_label.text = ""

func _unhandled_input(event: InputEvent) -> void:
	# Pressing Escape closes the computer interface
	if event.is_action_pressed("ui_cancel"):
		queue_free()
