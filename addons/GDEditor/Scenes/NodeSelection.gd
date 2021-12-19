tool

extends ItemList

func get_drag_data(position: Vector2):
	var selected_id := get_item_at_position(position)
	var selected_text := get_item_text(selected_id)
	var p : PackedScene = load(GDUtil.resolve(selected_text + ".tscn"))
	var preview_control : GraphNode = p.instance()
	
	preview_control.rect_scale = Vector2(0.5, 0.5)
	set_drag_preview(preview_control)
	
	return {
		"value_type": "GDComponent",
		"payload": p
	}
