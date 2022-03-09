tool

extends Control


class_name GDGraphEditorContainer


func get_editor(idx: int) -> GDGraphEditor:
	return get_child(idx) as GDGraphEditor


func get_active_editor() -> GDGraphEditor:
	var tabs : Tabs = GDUtil.get_dialogue_editor().get_tabs()
	
	return get_editor(tabs.current_tab) 


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


func add_editor(graph_editor: GDGraphEditor, idx := -1) -> void:
	add_child(graph_editor)

	if not graph_editor.is_inside_tree():
		yield(graph_editor, "ready")
	
	if not idx == -1:
		move_child(graph_editor, idx)


func remove_editor(idx: int) -> void:
	if idx >= 0 and idx < get_child_count():
		get_child(idx).queue_free()


func save_editor(idx: int, file_name: String) -> void:
	get_child(idx).save(file_name)


func save_editors() -> void:
	for graph_editor in get_children():
		graph_editor.save()


func clear() -> void:
	for child in get_children():
		child.free()
