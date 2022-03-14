tool

extends VSplitContainer

onready var _views := $Views
onready var _graphs := $Graphs

var port_maps: Array
var dialogue_datas: Array


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


func _on_graph_node_add(tab: int, gn: GDGraphNode) -> void:
	pass # Replace with function body.


func _on_graph_node_added(tab: int, gn: GDGraphNode) -> void:
	pass # Replace with function body.


func _on_graph_node_removed(tab: int, gn: GDGraphNode) -> void:
	pass # Replace with function body.
