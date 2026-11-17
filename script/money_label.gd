extends Label
## Keeps the "Money" HUD label in sync with GameData.coins.

func _ready() -> void:
	_update(GameData.coins)
	GameData.coins_changed.connect(_update)

func _update(total: int) -> void:
	text = "Money: $%d" % total
