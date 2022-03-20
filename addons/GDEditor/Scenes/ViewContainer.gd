tool

extends PanelContainer

signal view_add(view)
signal view_active(view)
signal view_next(tab)
signal view_removed


var active_view: GDDialogueView

var _removing_view := false

func get_view(tab: int) -> GDDialogueView:
	return get_child(tab) as GDDialogueView


func show_view(index: int) -> void:
	while _removing_view:
		yield(self, "view_removed")
	
	for view in get_children():
		if view.get_index() == index:
			view.show()
			active_view = view
			
			emit_signal("view_active", active_view)
		else:
			view.hide()


func add_view(view: GDDialogueView) -> void:
	emit_signal("view_add", view)
	
	view.connect("next", self, "_on_view_next", [view])
	
	add_child(view)
	show_view(view.get_index())


func move_view(from: int, to: int) -> void:
	move_child(get_child(from), to)


func free_view(index: int) -> void:
	var view: GDDialogueView = get_child(index)
	
	view.queue_free()
	
	_removing_view = true
	
	if is_instance_valid(view):
		yield(view, "tree_exited")
	
	_removing_view = false


func _on_view_next(view: GDDialogueView) -> void:
	emit_signal("view_next", view.get_index())
