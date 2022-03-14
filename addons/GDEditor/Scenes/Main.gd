tool

extends VSplitContainer

onready var _views := $Views
onready var _graphs := $Graphs

var port_maps := []
var dialogue_datas := []


func tab_add_empty() -> void:
	var dv = load(GDUtil.resolve("GDStandardView.tscn")).instance()
	var graph = load(GDUtil.resolve("DialogueGraph.tscn")).instance()
	
	_views.add_view(dv)
	_graphs.add_graph(graph)


func tab_show(tab: int) -> void:
	_views.show_view(tab)
	_graphs.show_graph(tab)


func tab_move(from: int, to: int) -> void:
	_views.move_view(from, to)
	_graphs.move_graph(from, to)
	
	var pm = port_maps[from]
	var dd = dialogue_datas[from]
	
	dialogue_datas[from] = dialogue_datas[to]
	dialogue_datas[to] = dd
	
	port_maps[from] = port_maps[to]
	port_maps[to] = pm 


func tab_close(index: int) -> void:
	_views.free_view(index)
	_graphs.free_graph(index)
	
	dialogue_datas.remove(index)
	port_maps.remove(index)


func tab_save(index: int) -> void:
	# temporary... testing only
	_graphs.save_graph(index, "res://addons/GDEditor/Saves/save.tscn")


func _on_graph_node_add(tab: int, gn: GDGraphNode) -> void:
	pass # Replace with function body.


func _on_graph_node_added(tab: int, gn: GDGraphNode) -> void:
	pass # Replace with function body.


func _on_graph_node_removed(tab: int, gn: GDGraphNode) -> void:
	pass # Replace with function body.


func _on_graph_added(graph: DialogueGraph) -> void:	
	dialogue_datas.append(GDDialogueData.new())
	port_maps.append(graph.port_map())
