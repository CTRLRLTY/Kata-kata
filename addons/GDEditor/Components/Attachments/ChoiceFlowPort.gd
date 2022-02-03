tool

extends HBoxContainer

signal remove_choice


func _on_RemoveChoice_pressed() -> void:
	emit_signal("remove_choice")
