extends CanvasLayer

@onready var reason_label: Label = $Panel/VBoxContainer/Reason

func _ready() -> void:
	# Esconder inicialmente
	hide()

func show_game_over(reason: String) -> void:
	reason_label.text = reason
	show()

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
