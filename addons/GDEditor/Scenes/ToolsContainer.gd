tool

extends HBoxContainer

var _tools_state := {}


func _exit_tree() -> void:
	for key in _tools_state:
		_tools_state[key].queue_free()
		_tools_state.erase(key)


func get_dialogue_editor() -> Control:
	return GDUtil.get_dialogue_editor()


func set_tools(tools: Array) -> void:
	clear_tools()
	add_tools(tools)


func save() -> void:
	for child in get_children():
		if child.has_method("save"):
			child.save


func add_child(btn: Node, legible_unique_name := false) -> void:
	assert(btn is TextureButton, "ToolsContainer child must be a texture button")
	
	btn.expand = true
	btn.rect_min_size = Vector2(26, 26)
	
	.add_child(btn)


func add_tools(tools: Array) -> void:
	for tool_scene in tools:
		assert(tool_scene is PackedScene)
		
		if not _tools_state.has(tool_scene):
			var graph_editor_container : Control = get_dialogue_editor().get_graph_editor_container()
			var dialogue_view : GDDialogueView = graph_editor_container.get_editor_preview(
					get_dialogue_editor().get_tabs().current_tab)
			
			_tools_state[tool_scene] = tool_scene.instance()
			_tools_state[tool_scene].set_dialogue_view(dialogue_view)
		
		if not _tools_state[tool_scene].get_parent():
			add_child(_tools_state[tool_scene])


func clear_tools() -> void:
	for child in get_children():
		remove_child(child)


func empty() -> bool:
	return not get_child_count() as bool
