tool

extends Node

signal event(event_name)
signal dialogue_end


static func render_data(dv: GDDialogueView, data: GDDialogueData, cursor: GDDialogueCursor) -> void:
	var node_name := cursor.current
	var d = data.data_table[node_name]
	var readers = data.reader_table[node_name]
	
	print_debug("rendering %s" % node_name)
	
	for reader in readers:
		reader.render(d, dv, cursor)


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
		
		view.connect("dialogue_end", self, "_on_view_end", [view])
		
		_viewers.add_child(view)
	
	view.reset()
	view.set_dialogue_data(data)
	_show_view(view)


func set_view_layer(layer: int) -> void:
	_viewers.layer = layer


func get_view_layer() -> int:
	return _viewers.layer


func _show_view(view: GDDialogueView) -> void:
	for child in _viewers.get_children():
		child.visible = child == view


func _on_view_end(view: GDDialogueView) -> void:
	view.hide()
	emit_signal("dialogue_end")
