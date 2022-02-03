tool

extends ItemList


func get_drag_data(position: Vector2):
	var idx := get_item_at_position(position)
	var p : PackedScene = get_item_metadata(idx)
	var preview_control : GDGraphNode = p.instance()
	
	preview_control.rect_scale = Vector2(0.5, 0.5)
	set_drag_preview(preview_control)
	
	return {
		"value_type": "GDGraphNodeScene",
		"payload": p
	}
