tool

extends ItemList

#func _enter_tree() -> void:
#	clear()
#
#	var d := Directory.new()
#	d.open(GDUtil.get_component_dir())
#	d.list_dir_begin(true, true)
#
#	var file_name := d.get_next()
#	while not file_name.empty():
#		var ext := file_name.get_extension()
#
#		if ext == "tscn":
#			var basename := file_name.get_basename()
#			add_item(basename)
#
#		file_name = d.get_next()
#
#	d.list_dir_end()


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
