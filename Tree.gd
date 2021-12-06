extends Tree

func _ready() -> void:
	var root = create_item()
	set_hide_root(true)
	var child1 = create_item(root)
	var child2 = create_item(root)
	var child3 = create_item(root)
	child1.set_text(0, "hi")
	var godot_icon = load("res://icon.png")
	print(godot_icon)

#	child1.set_cell_mode(1, TreeItem.CELL_MODE_ICON)

	child1.set_custom_color(0, Color(1,1,1,1))

	child1.set_text(0, "hello")
	child1.set_icon(0, godot_icon)
	child1.set_icon_max_width(0, 16)
	child1.add_button(0, godot_icon, 0, true)
	
	print(child1)
	print(child1.get_next())
	print(child1.get_next().get_next())

	
