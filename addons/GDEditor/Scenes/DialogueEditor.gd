tool

extends Control

class_name GDDialogueEditor


onready var tabs := find_node("Tabs")
onready var character_definition := find_node("CharacterDefinitionPopup")
onready var node_selection := find_node("node_selection")
onready var graph_editor_container := find_node("GraphEditorContainer")


func _ready() -> void:
	GDUtil.set_dialogue_editor(self)
	
	if not graph_editor_container.get_editor_count():
		tabs.emit_signal("tab_added")


func get_character_names() -> PoolStringArray:
	var character_names := PoolStringArray([])
	
	for character_data in character_definition.get_character_datas():
		character_names.append(character_data.character_name)

	return character_names


func _on_TabMenuPopup_save_dialogue() -> void:
	graph_editor_container.save_editor(tabs.current_tab)


func _on_TabMenuPopup_preview_dialogue() -> void:
	var dialogue_preview : GDDialogueView = graph_editor_container.get_editor_preview(tabs.current_tab)
	dialogue_preview.visible = not dialogue_preview.visible
	dialogue_preview.clear()
	
	graph_editor_container.save_editor(tabs.current_tab)


func _on_Tabs_tab_added() -> void:
	graph_editor_container.add_editor()
	# wait till editor is added
	yield(get_tree(), "idle_frame")
	
	var current_tab: int = tabs.get_tab_count() - 1
	
	tabs.set_current_tab(current_tab)
	graph_editor_container.show_editor(current_tab)
	
	var dialogue_preview : GDDialogueView = graph_editor_container.get_editor_preview(tabs.current_tab)
	
	dialogue_preview.connect("next", self, "_on_dialogue_view_next", [dialogue_preview])
	dialogue_preview.connect("choice", self, "_on_dialogue_view_choice", [dialogue_preview])


func _on_Tabs_tab_changed(tab: int) -> void:
	graph_editor_container.show_editor(tab)


func _on_dialogue_view_next(dialogue_view: GDDialogueView) -> void:
	var dgraph : DialogueGraph = graph_editor_container.get_editor_graph(tabs.current_tab)
	var cursor := dgraph.cursor()
	
	if cursor.is_invalid():
		return
	
	if cursor.is_start():
		cursor.next()
	
	if cursor.is_end():
		cursor.reset()
		dialogue_view.clear()
	
	var current := cursor.current()
	var graph_node : GraphNode = dgraph.get_node(current.name)
	
	for reader in dialogue_view.get_readers():
		if reader is GDDialogueReader:
			if reader.can_handle(graph_node):
				reader.render(graph_node, dialogue_view)
	
	cursor.next()


func _on_dialogue_view_choice(choice: int, dialogue_view: GDDialogueView) -> void:
	pass
