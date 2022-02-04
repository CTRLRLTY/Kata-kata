tool

extends HBoxContainer


func add_child(btn: Node, legible_unique_name := false) -> void:
	assert(btn is TextureButton)
	
	btn.expand = true
	btn.rect_min_size = Vector2(26, 26)
	
	.add_child(btn)


func add_tools(tools: Array) -> void:
	for tool_scene in tools:
		assert(tool_scene is PackedScene)
		var tool_btn: TextureButton = tool_scene.instance()
		add_child(tool_btn)


func clear_tools() -> void:
	for child in get_children():
		child.free()


func empty() -> bool:
	return not get_child_count() as bool
