class_name AppData
extends Resource

enum AppID { BANK, STOCKS, MAIL, EBAY, GAMBLING, JOBS, NEWS, TYPING_GAME }

@export var app_id: AppID
@export var app_name: String
@export var app_scene: PackedScene
@export var is_office_only: bool = false
