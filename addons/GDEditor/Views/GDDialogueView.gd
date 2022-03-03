tool

extends Control

class_name GDDialogueView

signal next
signal choice(idx)

var _components := []
var _reader_table := {}
var _tools_tested := false
var _dgraph : GraphEdit


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				next()
				emit_signal("next")


func get_components() -> Array:
	if _components.empty():
		for component in _dialogue_components():
			assert(component is Dictionary or component is PackedScene)
			
			if component is PackedScene:
				var c := {}
				var scene = component.instance()
				
				assert(scene is GDGraphNode)
				
				c["readers"] = scene.get_readers()
				c["scene"] = component
				c["name"] = scene.get_component_name()
				
				for reader in c.readers:
					assert(reader is GDDialogueReader)
				
				_reader_table[component.resource_path] = c.readers
				
				scene.free()
				_components.append(c)
				
			elif component is Dictionary:
				assert(component.has("scene"))
				assert(component.scene is PackedScene)
				
				var scene = component.scene.instance()
				assert(scene is GDGraphNode)
				
				component.readers = component.get("readers", scene.get_readers())
				component.name = component.get("name", scene.get_component_name())
				
				scene.free()
				
				assert(component.readers is Array)
				
				var scene_path = component.scene.resource_path
				
				for reader in component.readers:
					assert(reader is GDDialogueReader)
				
				_reader_table[scene_path] = component.readers
				
				_components.append(component)
	
	return _components


func get_tools() -> Array:
	if not _tools_tested:
		for tool_scene in _tool_buttons():
			assert(tool_scene is PackedScene)
			
			var scene = tool_scene.instance()
			
			assert(scene is GDDialogueTool)
			
			scene.free()
	
		_tools_tested = true
	
	return _tool_buttons()


func get_dialogue_graph() -> GraphEdit:
	return _dgraph


func set_dialogue_graph(dgraph: GraphEdit) -> void:
	_dgraph = dgraph


func set_text_box(text: String) -> void:
	pass


func render_node(node: GDGraphNode, cursor: GDDialogueCursor) -> void:
	for reader in _reader_table[node.filename]:
		reader.render(node, self, cursor)


func next() -> void:
	var dgraph := get_dialogue_graph()
	
	var cursor : GDDialogueCursor = dgraph.cursor()
	
	if not cursor.is_connected("flow_skipped", self, "__on_cursor_flow_skipped"):
		cursor.connect("flow_skipped", self , "__on_cursor_flow_skipped")
	
	if cursor.end():
		return
	
	var node_name := cursor.get_node_name()
	var graph_node : GDGraphNode = dgraph.get_node(node_name)
	
	var actions_left : Array = cursor.port_lefta()
	var actions_right : Array = cursor.port_righta()
	
	
	for port in actions_left:
		for cursor_copy in cursor.branch_lefta(port):
			cursor_copy.connect("prev", self, "__on_cursor_prev", [cursor_copy])
			
			var gn : GDGraphNode = dgraph.get_node(cursor_copy.get_node_name())
			
			render_node(gn, cursor_copy)
	
	
	for port in actions_right:
		for cursor_copy in cursor.branch_righta(port):
			cursor_copy.connect("next", self, "__on_cursor_next", [cursor_copy])
			
			var gn : GDGraphNode = dgraph.get_node(cursor_copy.get_node_name())
			
			render_node(gn, cursor_copy)
	
	render_node(graph_node, cursor)



func show_choices(question: PoolStringArray) -> void:
	pass


func hide_choices() -> void:
	pass


func clear_choices() -> void:
	pass


func reset() -> void:
	pass


func save() -> void:
	pass


func _dialogue_components() -> Array:
	return []


func _tool_buttons() -> Array:
	return []


func __on_cursor_next(cursor: GDDialogueCursor) -> void:
	print_debug("action: " + cursor.get_node_name())


func __on_cursor_prev(cursor: GDDialogueCursor) -> void:
	pass


func __on_cursor_flow_skipped():
	next()
