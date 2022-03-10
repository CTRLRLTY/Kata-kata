tool

extends VSplitContainer

class_name GDGraphEditor

# GDDialogueData
export var dialogue_data : Resource = null
# GDDialogueCursor
export var cursor : Resource = null

onready var _main := $MainContainer
onready var _node_selection := find_node("NodeSelection")
onready var _state_tree := _main.find_node("ContextStateTree")


func _ready() -> void:
	var port_map : GDPortMap = get_dialogue_graph().port_map()
	
	if not dialogue_data:
		dialogue_data = GDDialogueData.new()
	
	if not cursor:
		cursor = GDDialogueCursor.new()
	
	# This is to link our cursor port_map with the dialogue_graph port_map, 
	# since they are passed by reference
	cursor.pt = port_map
	
	cursor.connect("reset", self, "_on_cursor_reset")
	cursor.connect("end", self, "_on_cursor_end")
	
	if not get_dialogue_preview():
		var standard_view : GDDialogueView = load(
				GDUtil.resolve("GDStandardView.tscn")).instance()
		
		set_dialogue_preview(standard_view)
	else:
		_setup_preview()
	
	get_dialogue_graph().owner = self
	


func get_dialogue_preview() -> GDDialogueView:
	var first_child : Node = get_child(0)
	
	if first_child is GDDialogueView:
		return first_child as GDDialogueView
	else:
		return null


func get_dialogue_graph() -> DialogueGraph:
	var gd := _main.get_child(1) as DialogueGraph
	
	return gd


func get_state_tree() -> GDContextStateTree:
	return _state_tree as GDContextStateTree


func set_dialogue_graph(dgraph: DialogueGraph) -> void:
	var current_dgraph : DialogueGraph = get_dialogue_graph()
	
	if is_instance_valid(current_dgraph):
		current_dgraph.queue_free()
	
	dgraph.connect("graph_node_add", self, "_on_graph_node_add")
	dgraph.connect("graph_node_added", self, "_on_graph_node_added")
	dgraph.connect("graph_node_removed", self, "_on_graph_node_removed")
	
	dgraph.owner = self
	_main.add_child(dgraph)


func set_dialogue_preview(dialogue_view: GDDialogueView) -> void:
	dialogue_view.hide()
	
	var current_dialogue_view := get_dialogue_preview()
	
	dialogue_view.set_dialogue_graph(get_dialogue_graph())
	
	if current_dialogue_view:
		current_dialogue_view.queue_free()
		
		add_child(dialogue_view)
		move_child(dialogue_view, 0)
	else:
		add_child(dialogue_view)
		move_child(dialogue_view, 0)
	
	dialogue_view.owner = self
	
	yield(get_tree(), "idle_frame")
	
	_setup_preview()


func save(file_path: String) -> void:
	var d := Directory.new()
	
	if not d.dir_exists(GDUtil.get_save_dir()):
		d.make_dir(GDUtil.get_save_dir())
	
	var packer := PackedScene.new()
	var dv := get_dialogue_preview()
	var dg := get_dialogue_graph()
	
	dg.save()
	dv.save()
	
	dialogue_data.view_path = dv.filename
	
	var port_map : GDPortMap = get_dialogue_graph().port_map()
	
	cursor.pt = port_map
	
	# Last update
	for gn in dg.get_children():
		if gn is GDGraphNode:
			var node_name : String = gn.name
			
			# disconnect dangling nodes
			if gn.get_depth() == 0:
				port_map.clear_left(node_name)
			
			dialogue_data.data_table[node_name] = gn.get_save_data()
			
			if gn is GDStartGN:
				if port_map.right_connected(node_name, 0):
					cursor.root = node_name
				else:
					port_map.set_node_depth(node_name, 0)
	
	cursor.current = cursor.root
	
	packer.pack(self)
	
	ResourceSaver.save(file_path, packer)
#	ResourceSaver.save(GDUtil.get_save_dir()+"test.tres", dialogue_data)


func _setup_preview() -> void:
	_node_selection.clear()
	
	var dialogue_view := get_dialogue_preview()
	dialogue_view.set_dialogue_graph(get_dialogue_graph())
	
	dialogue_view.connect("next", self, "_on_dialogue_next")
	
	for component in dialogue_view.get_components():
		var component_scene : PackedScene = component.scene
		
		var idx : int = _node_selection.get_item_count()
		var gn : GDGraphNode = component_scene.instance()
		
		_node_selection.add_item(component.name)
		_node_selection.set_item_metadata(idx, component_scene)


func _on_graph_node_add(gn: GDGraphNode) -> void:
	gn.set_graph_editor(self)


func _on_graph_node_added(gn: GDGraphNode) -> void:
	var reader_table := get_dialogue_preview().get_reader_table()
	var readers : Array = reader_table[gn.filename]
	var node_name := gn.name
	
	dialogue_data.reader_table[node_name] = readers
	dialogue_data.data_table[node_name] = gn.get_save_data()
	
	if gn is GDStartGN:
		cursor.root = node_name
		cursor.current = node_name
	
	gn.connect("value_updated", self, "_on_graph_node_value_updated", [gn])


func _on_graph_node_removed(node_name: String) -> void:
	dialogue_data.reader_table.erase(node_name)
	dialogue_data.data_table.erase(node_name)


# Only matters in editor
func _on_graph_node_value_updated(gn: GDGraphNode) -> void:
	dialogue_data.data_table[gn.name] = gn.get_save_data()


func _on_dialogue_next() -> void:
	cursor.pt = get_dialogue_graph().port_map()
	
	get_dialogue_preview().render_data(dialogue_data, cursor)


func _on_cursor_reset() -> void:
	get_dialogue_preview().reset()


func _on_cursor_end() -> void:
	cursor.reset()
