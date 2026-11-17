extends TextureButton

signal app_launched(app_data: AppData)

var current_app_data: AppData

func setup(app_data: AppData) -> void:
	current_app_data = app_data
	$Label.text = app_data.app_name

func _on_pressed() -> void:
	if current_app_data:
		app_launched.emit(current_app_data)
