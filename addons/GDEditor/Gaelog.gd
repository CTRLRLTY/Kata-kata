extends Node

signal event(event_name)


var view_layer : int setget set_view_layer, get_view_layer


onready var _viewers := $Viewers


func show_dialogue(data : GDDialogueData) -> void:
	if data.view_path.empty():
		return
	
	var has_view := false
	var view : GDDialogueView
	
	for child in _viewers.get_children():
		if child.filename == data.view_path:
			has_view = true
			view = child
			break
	
	if not has_view:
		view = load(data.view_path).instance()
		_viewers.add_child(view)
	
	view.set_dialogue_data(data)
	_show_view(view)


func set_view_layer(layer: int) -> void:
	_viewers.layer = layer


func get_view_layer() -> int:
	return _viewers.layer


func _show_view(view: GDDialogueView) -> void:
	for child in _viewers.get_children():
		child.visible = child == view
