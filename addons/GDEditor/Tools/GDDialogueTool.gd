tool

extends TextureButton

class_name GDDialogueTool

var _dialogue_view : Control


func get_dialogue_view() -> Control:
	return _dialogue_view


func set_dialogue_view(dialogue_view: Control) -> void:
	_dialogue_view = dialogue_view
