tool

extends Control

class_name GDDialogueView

signal next

signal choice_selected(idx)
signal dialogue_end

var _tools_tested := false
var _dgraph : GraphEdit

var _blocked := false

var _dialogue_data : GDDialogueData


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				next()


func get_view_name() -> String:
	return "Dialogue View"


func get_reader_table() -> Dictionary:
	var reader_table := {}
	
	for component in _dialogue_components():
		if component is PackedScene:
			var scene : GDGraphNode = component.instance()
			
			assert(scene is GDGraphNode)
			
			var readers := scene.get_readers()
			
			reader_table[component.resource_path] = readers
			
			scene.free()
			
		elif component is Dictionary:
			assert(component.has("scene"))
			assert(component.scene is PackedScene)
			
			var scene : GDGraphNode = component.scene.instance()
			
			assert(scene is GDGraphNode)
			
			var readers : Array = component.get("readers", scene.get_readers())
			
			reader_table[component.scene.resource_path] = readers
			
			scene.free()
	
	return reader_table



func get_components() -> Array:
	var components := []
	
	for component in _dialogue_components():
		assert(component is Dictionary or component is PackedScene)
		
		if component is PackedScene:
			var c := {}
			var scene = component.instance()
			
			assert(scene is GDGraphNode)
			
			c["scene"] = component
			c["name"] = scene.get_component_name()
			
			scene.free()
			components.append(c)
			
		elif component is Dictionary:
			assert(component.has("scene"))
			assert(component.scene is PackedScene)
			
			var scene = component.scene.instance()
			assert(scene is GDGraphNode)
			
			component.name = component.get("name", scene.get_component_name())
			
			scene.free()
			
			components.append(component)
	
	return components


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


func set_dialogue_data(data: GDDialogueData) -> void:
	_dialogue_data = data
	
	var cursor : GDDialogueCursor = _dialogue_data.cursor
	
	if not cursor.is_connected("skipped", self, "__on_cursor_skipped"):
		cursor.connect("skipped", self , "__on_cursor_skipped")


func block_next(block: bool) -> void:
	_blocked = block


func render_node(node_name: String, cursor: GDDialogueCursor) -> void:
	assert(_dialogue_data, "_dialogue_data must be set before calling render_node()")
	
	var data = _dialogue_data.data_table[node_name]
	var readers = _dialogue_data.reader_table
	
	for reader in readers[node_name]:
		reader.render(data, self, cursor)


func next() -> void:
	if not _dialogue_data:
		print_debug("_dialogue_data must be set before calling next()")
		return
	
	if _blocked:
		return
	
	var cursor : GDDialogueCursor = _dialogue_data.cursor
	
	var node_name := cursor.current
	
	render_node(node_name, cursor)
	
	emit_signal("next")


func select_choice(idx: int) -> void:
	emit_signal("choice_selected", idx)


func set_text_box(text: String) -> void:
	pass


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


func __on_cursor_skipped():
	next()
