tool

extends Control

class_name GDDialogueView

signal next
signal choice(idx)

var _components := []
var _reader_table := {}
var _tools_tested := false


func get_components() -> Array:
	if _components.empty():
		for component in _get_components():
			assert(component is Dictionary or component is PackedScene)
			
			if component is PackedScene:
				var c := {}
				var scene = component.instance()
				assert(scene is GDGraphNode)
				
				c["readers"] = []
				c["scene"] = component
				c["name"] = scene.get_component_name()
				
				scene.free()
				_components.append(c)
			elif component is Dictionary:
				assert(component.has("scene"))
				assert(component.scene is PackedScene)
				
				var scene = component.scene.instance()
				assert(scene is GDGraphNode)
				
				component.readers = component.get("readers", [])
				component.name = component.get("name", scene.get_component_name())
				
				scene.free()
				
				assert(component.readers is Array)
				
				var scene_path = component.scene.resource_path
				_reader_table[scene_path] = component.readers
				
				for reader in component.readers:
					assert(reader is GDDialogueReader)
				
				_components.append(component)
	
	return _components


func get_tools() -> Array:
	if not _tools_tested:
		for tool_scene in _get_tools():
			assert(tool_scene is PackedScene)
			
			var scene = tool_scene.instance()
			
			assert(scene is GDDialogueTool)
			
			scene.free()
	
		_tools_tested = true
	
	return _get_tools()


func set_text_box(text: String) -> void:
	pass


func render_node(node: GDGraphNode, cursor: GDDialogueCursor) -> void:
	for reader in _reader_table[node.filename]:
		reader.render(node, self, cursor)


func next() -> void:
	emit_signal("next")


func show_choices(question: PoolStringArray) -> void:
	pass


func hide_choices() -> void:
	pass


func clear_choices() -> void:
	pass


func clear() -> void:
	pass


func save() -> void:
	pass


func _get_components() -> Array:
	return []


func _get_tools() -> Array:
	return []
