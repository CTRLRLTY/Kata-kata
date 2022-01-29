tool

extends Control

onready var main := find_node("MainContainer")
onready var tabs := find_node("Tabs")
onready var dialogue_preview := find_node("DialoguePreview")


func _ready() -> void:
	dialogue_preview.connect("next", self, "_on_dialogue_view_next", [dialogue_preview])
	dialogue_preview.connect("choice", self, "_on_dialogue_view_choice", [dialogue_preview])


func get_dialogue_graphs() -> Array:
	var graph_list := []

	for child in main.get_children():
		if child is DialogueGraph:
			graph_list.append(child)

	return graph_list


func get_dialogue_graph(idx: int) -> DialogueGraph:
	return get_dialogue_graphs()[idx]


func show_dialogue_graph(idx: int) -> void:
	var acc := 0
	for dgraph in get_dialogue_graphs():
		dgraph.visible = acc == idx
		
		acc += 1


func _on_TabMenuPopup_save_dialogue() -> void:
	var graph_list := get_dialogue_graphs()
	
	for dgraph in graph_list:
		dgraph.save()


func _on_TabMenuPopup_preview_dialogue() -> void:
	dialogue_preview.visible = not dialogue_preview.visible
	get_dialogue_graph(tabs.current_tab).save()


func _on_Tabs_tab_added() -> void:
	var dgraph: DialogueGraph = load(GDUtil.resolve("DialogueGraph.tscn")).instance()
	
	main.add_child(dgraph)
	
	if not dgraph.is_inside_tree():
		yield(dgraph, "ready")
	
	show_dialogue_graph(tabs.current_tab)


func _on_Tabs_tab_changed(tab: int) -> void:
	show_dialogue_graph(tab)


func _on_dialogue_view_next(dialogue_view: GDDialogueView) -> void:
	var dgraph := get_dialogue_graph(tabs.current_tab)
	var cursor := dgraph.cursor()
	
	if cursor.is_invalid():
		return
	
	if cursor.is_start():
		cursor.next()
	
	if cursor.is_end():
		cursor.reset()
	
	var current := cursor.current()
	var graph_node : GDGraphNode = dgraph.get_node(current.name)
	
	for reader in dialogue_view.get_readers():
		assert(reader is GDDialogueReader)
		
		if reader.can_handle(graph_node):
			reader.render(graph_node, dialogue_view)
	
	cursor.next()


func _on_dialogue_view_choice(choice: int, dialogue_view: GDDialogueView) -> void:
	pass
