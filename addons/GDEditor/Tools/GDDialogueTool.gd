tool

extends TextureButton

class_name GDDialogueTool

var _dialogue_view : GDDialogueView


func get_dialogue_view() -> GDDialogueView:
	return _dialogue_view


func set_dialogue_view(dialogue_view: GDDialogueView) -> void:
	_dialogue_view = dialogue_view
