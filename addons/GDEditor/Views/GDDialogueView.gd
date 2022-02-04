tool

extends Control

class_name GDDialogueView

signal next
signal choice(idx)


func get_readers() -> Array:
	return []


func get_components() -> Array:
	return []


func get_tools() -> Array:
	return []


func get_tools_shared() -> Array:
	return []


func set_text_box(text: String) -> void:
	pass


func next() -> void:
	emit_signal("next")


func show_choices(question: PoolStringArray) -> void:
	pass


func hide_choices() -> void:
	pass


func clear_choices() -> void:
	pass


func clear() -> void:
	pass


func save() -> void:
	pass
