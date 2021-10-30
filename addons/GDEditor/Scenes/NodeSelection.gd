tool

extends ItemList

func get_drag_data(position: Vector2):
	var component_dir = "res://addons/GDEditor/Scenes/Components/"
	var selected_id := get_item_at_position(position)
	var selected_text := get_item_text(selected_id)
	var component_path : String = component_dir + selected_text + "Node.tscn"
	var p : PackedScene = load(component_path)
	var preview_control : GraphNode = p.instance()
	
	preview_control.rect_scale = Vector2(0.5, 0.5)
	set_drag_preview(preview_control)
	
	return {
		"value_type": "GDComponent",
		"payload": p
	}
