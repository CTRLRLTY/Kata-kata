tool

extends PanelContainer

signal view_added(view)
signal view_active(view)
signal view_active_next
signal view_removed


####################################################
#	External Variable
####################################################
# This variable is managed externally, don't touch..

var active_view: GDDialogueView
####################################################

var _removing_view := false

func show_view(index: int) -> void:
	while _removing_view:
		yield(self, "view_removed")
	
	for view in get_children():
		if view.get_index() == index:
			view.show()
			emit_signal("view_active", view)
		else:
			view.hide()


func add_view(view: GDDialogueView) -> void:
	view.connect("next", self, "_on_view_next", [view])
	
	add_child(view)
	show_view(view.get_index())
	
	emit_signal("view_added", view)


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
	if view == active_view:
		emit_signal("view_active_next")
