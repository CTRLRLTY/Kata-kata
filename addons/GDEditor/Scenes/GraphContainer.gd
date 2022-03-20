tool

extends PanelContainer

signal graph_active(graph)
signal graph_add(graph)

signal graph_node_add(tab, gn)
signal graph_node_added(tab, gn)
signal graph_node_removed(tab, node_name)

signal graph_removed

var _removing_graph := false

func get_graph(tab: int) -> DialogueGraph:
	return get_child(tab) as DialogueGraph


func add_graph(graph: DialogueGraph) -> void:
	emit_signal("graph_add", graph)
	
	graph.connect("graph_node_add", self, "_on_graph_node_add", [graph])
	graph.connect("graph_node_added", self, "_on_graph_node_added", [graph])
	graph.connect("graph_node_removed", self, "_on_graph_node_removed", [graph])
	
	add_child(graph)
	show_graph(graph.get_index())


func show_graph(index: int) -> void:
	while _removing_graph:
		yield(self, "graph_removed")
	
	for graph in get_children():
		if graph.get_index() == index:
			graph.show()
			emit_signal("graph_active", graph)
		else:
			graph.hide()


func move_graph(from:int, to: int) -> void:
	move_child(get_child(from), to)


func free_graph(index: int) -> void:
	var graph: DialogueGraph = get_child(index)
	graph.queue_free()
	
	_removing_graph = true
	
	if is_instance_valid(graph):
		yield(graph, "tree_exited")
	
	_removing_graph = false


func save_graph(index: int, path: String, data: GDDialogueData) -> void:
	var packed := PackedScene.new()
	var graph: DialogueGraph = get_child(index)
	
	graph.set_meta("dialogue_data", data)
	packed.pack(graph)
	
	ResourceSaver.save(path, packed)


func _on_graph_node_add(gn: GDGraphNode, graph: DialogueGraph) -> void:
	emit_signal("graph_node_add", graph.get_index(), gn)


func _on_graph_node_added(gn: GDGraphNode, graph: DialogueGraph) -> void:
	emit_signal("graph_node_added", graph.get_index(), gn)


func _on_graph_node_removed(node_name: String, graph: DialogueGraph) -> void:
	emit_signal("graph_node_removed", graph.get_index(), node_name)
