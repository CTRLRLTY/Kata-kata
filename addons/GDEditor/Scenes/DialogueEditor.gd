tool

extends PanelContainer

onready var main: HSplitContainer = find_node("MainContainer")
onready var tabs: Tabs = find_node("Tabs")


func get_dialogue_graphs() -> Array:
	var graph_list := []

	for child in main.get_children():
		if child is GraphEdit:
			graph_list.append(child)

	return graph_list


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
	pass # Replace with function body.


func _on_Tabs_tab_added() -> void:
	var dgraph: DialogueGraph = load(GDUtil.resolve("DialogueGraph.tscn")).instance()
	
	main.add_child(dgraph)
	
	if not dgraph.is_inside_tree():
		yield(dgraph, "ready")
	
	show_dialogue_graph(tabs.current_tab)


func _on_Tabs_tab_changed(tab: int) -> void:
	show_dialogue_graph(tab)
