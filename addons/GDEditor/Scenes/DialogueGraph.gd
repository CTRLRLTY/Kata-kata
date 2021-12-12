tool

extends GraphEdit


func can_drop_data(_position: Vector2, data) -> bool:
	return data is Dictionary and data.get("value_type", "") == "GDComponent" 
	
	
func drop_data(position: Vector2, data : Dictionary) -> void:
	var gn : GraphNode = data.payload.instance()
	add_child(gn)
	gn.owner = owner
	gn.offset = (scroll_offset + position) / zoom
