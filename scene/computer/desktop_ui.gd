extends Window  # Changed from Control to Window

@onready var icon_grid: GridContainer = $IconGrid
@onready var app_container: Control = $AppContainer
@onready var active_app_label: Label = $TaskBar/HBoxContainer/ActiveAppLabel

var is_in_office: bool = false
var active_app_instance: Node = null

func _ready() -> void:
	# Automatically connect the native OS 'X' close button to shut down the computer
	close_requested.connect(func(): queue_free())

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
		# Create a sub-window wrapper for the app UI inside the desktop
		var sub_window = Window.new()
		sub_window.title = app.app_name
		sub_window.transient = true
		sub_window.resizable = true
		sub_window.size = Vector2i(600, 400)
		
		# Center the sub-window relative to this main desktop window
		sub_window.position = position + (size / 2) - (sub_window.size / 2)
		
		# Close app when its sub-window close button is clicked
		sub_window.close_requested.connect(close_current_app)
		
		# Instantiate the app inside the window frame
		var app_content = app.app_scene.instantiate()
		sub_window.add_child(app_content)
		
		# Add it to the container
		app_container.add_child(sub_window)
		active_app_instance = sub_window
		
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
