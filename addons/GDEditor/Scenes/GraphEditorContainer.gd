tool

extends Control


func get_editor(idx: int) -> GDGraphEditor:
	return get_child(idx) as GDGraphEditor


func get_active_editor() -> GDGraphEditor:
	for child in get_children():
		if child.visible:
			return child
	
	return null


func get_editor_graph(idx: int) -> DialogueGraph:
	return get_editor(idx).get_dialogue_graph() as DialogueGraph


func get_editor_preview(idx: int) -> GDDialogueView:
	return get_editor(idx).get_dialogue_preview() as GDDialogueView


func get_editor_count() -> int:
	return get_child_count()


func show_editor(idx: int) -> void:
	for child in get_children():
		child.hide()
	
	get_child(idx).show()


func add_editor(idx := -1) -> void:
	var graph_editor: Control = load(GDUtil.resolve("GraphEditor.tscn")).instance()
	
	add_child(graph_editor)

	if not graph_editor.is_inside_tree():
		yield(graph_editor, "ready")
	
	if not idx == -1:
		move_child(graph_editor, idx)


func save_editor(idx: int) -> void:
	get_child(idx).save()


func save_editors() -> void:
	for graph_editor in get_children():
		graph_editor.save()


func clear() -> void:
	for child in get_children():
		child.free()
