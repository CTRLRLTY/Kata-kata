tool

extends Control

class_name GDDialogueView

enum {
	OK = OK,
	ERR_BLOCKED
}


signal next

signal choice_selected(idx)
signal event(what)
signal dialogue_end

var _tools_tested := false
var _component_cache : Array

var _blocked := false

var _dialogue_data: GDDialogueData


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				next()


func next() -> int:
	if _blocked:
		return ERR_BLOCKED
		
	emit_signal("next")
	return OK


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
	if _component_cache:
		GDutil.print([self, " component chache hit!"], GDutil.PR_INFO, 4)
		return _component_cache
	
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
	
	_component_cache = components
	
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


func block_next(block: bool) -> void:
	_blocked = block


func render_data(data: GDDialogueData, cursor: GDDialogueCursor) -> void:
	var node_name := cursor.current
	
	if node_name.empty():
		print_debug(self, " Nothing to render...")
		return
	
	if not data.data_table.has(node_name):
		print_debug(self, " %s data record does not exist" % node_name)
		return
	
	var d = data.data_table[node_name]
	var readers = data.reader_table[node_name]
	
	print_debug(self, " rendering %s" % node_name)
	
	for reader in readers:
		reader.render(d, self, cursor)


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
