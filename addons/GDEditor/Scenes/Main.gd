tool

extends VSplitContainer

onready var _views := $Views
onready var _graphs := $Graphs


func tab_add_empty() -> void:
	var dv = load(GDutil.resolve("GDStandardView.tscn")).instance()
	var graph = load(GDutil.resolve("DialogueGraph.tscn")).instance()
	
	_views.add_view(dv)
	_graphs.add_graph(graph)


func tab_show(tab: int) -> void:
	_views.show_view(tab)
	_graphs.show_graph(tab)


func tab_move(from: int, to: int) -> void:
	_views.move_view(from, to)
	_graphs.move_graph(from, to)


func tab_close(index: int) -> void:
	_views.free_view(index)
	_graphs.free_graph(index)


func tab_save(index: int) -> void:
	# temporary... testing only
	_graphs.save_graph(index, "res://addons/GDEditor/Saves/save.tscn")


func view_next(tab: int) -> void:
	var view: GDDialogueView = _views.get_view(tab)
	var graph: DialogueGraph = _graphs.get_graph(tab)
	
	var cursor: GDDialogueCursor = view.get_meta("cursor")
	var dialogue_data: GDDialogueData = graph.get_meta("dialogue_data")
	var port_map: GDPortMap = graph.port_map
	
	cursor.pt = port_map
	
	if not cursor.is_connected('forwarded', self, "_on_cursor_forwarded"):
		cursor.connect('forwarded', self, "_on_cursor_forwarded", [tab])
	
	if not cursor.is_connected('end', self, "_on_cursor_end"):
		cursor.connect('end', self, "_on_cursor_end", [tab])
	
	if cursor.root.empty():
		for gn in graph.get_children():
			if gn is GDStartGN:
				cursor.root = gn.name
				cursor.current = gn.name
	
	if cursor.current.empty():
		cursor.current = cursor.root
	
	view.render_data(dialogue_data, cursor)


func _on_view_add(view) -> void:
	view.set_meta("cursor", GDDialogueCursor.new())


func _on_graph_add(graph: DialogueGraph) -> void:
	graph.set_meta("dialogue_data", GDDialogueData.new())
	graph.port_map = GDPortMap.new()


func _on_view_next(tab: int) -> void:
	view_next(tab)


func _on_cursor_forwarded(tab: int) -> void:
	view_next(tab)


func _on_cursor_end(tab: int) -> void:
	var view: GDDialogueView = _views.get_view(tab)
	var cursor: GDDialogueCursor = view.get_meta("cursor")
	
	view.reset()
	cursor.reset()


func _on_graph_node_add(tab: int, gn: GDGraphNode) -> void:
	var graph = _graphs.get_graph(tab)
	var view = _views.get_view(tab)
	
	gn.__dialogue_view__ = view
	gn.__port_map__ = graph.port_map


func _on_graph_node_added(tab: int, gn: GDGraphNode) -> void:
	var graph: DialogueGraph = _graphs.get_graph(tab)
	var view: GDDialogueView = _views.get_view(tab)
	
	var reader_table := view.get_reader_table()
	var readers: Array = reader_table[gn.filename]
	var node_name := gn.name
	
	var dialogue_data : GDDialogueData = graph.get_meta("dialogue_data")
	
	dialogue_data.reader_table[node_name] = readers
	dialogue_data.data_table[node_name] = gn.get_save_data()
	
	gn.connect("value_updated", self, "_on_graph_node_value_updated", [tab, gn])


func _on_graph_node_removed(tab: int, node_name: String) -> void:
	var dg: DialogueGraph = _graphs.get_graph(tab)
	var dialogue_data: GDDialogueData = dg.get_meta("dialogue_data")
	
	dialogue_data.reader_table.erase(node_name)
	dialogue_data.data_table.erase(node_name)


func _on_graph_node_value_updated(tab: int, gn: GDGraphNode) -> void:
	var dg: DialogueGraph = _graphs.get_graph(tab)
	var dialogue_data: GDDialogueData = dg.get_meta("dialogue_data")
	var node_name := gn.name
	
	dialogue_data.data_table[node_name] = gn.get_save_data()
