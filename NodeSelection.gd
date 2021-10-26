extends ItemList

func get_drag_data(position: Vector2):
	var preview_control := PanelContainer.new()
	var selected_item_id := get_item_at_position(position)
	set_drag_preview(preview_control)
	return "hello"
