tool

extends GDGraphNode

class_name GDStandardGN

enum ResizeDirection {
	HORIZONTAL,
	VERTICAL,
	BOTH
}

var resize_direction : int


func _get_property_list() -> Array:
	var prop := []
	PROPERTY_HINT_MULTILINE_TEXT
	
	prop.append({
		"name": "GDStandardNodeGN",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
	})
	
	prop.append({
		"name": "resize_direction",
		"hint": PROPERTY_HINT_ENUM,
		"usage": PROPERTY_USAGE_DEFAULT,
		"type": TYPE_INT,
		"hint_string": PoolStringArray(ResizeDirection.keys()).join(",")
	})
	
	return prop


func _get(property: String):
	match property:
		"resize_direction":
			return resize_direction


func _set(property: String, value):
	match property:
		"resize_direction":
			resize_direction = value
			return true
	
	return false


func _ready() -> void:
	resizable = true
	connect("resize_request", self, "_on_resize_request")


func _on_resize_request(_minsize: Vector2) -> void:
	var new_size := get_local_mouse_position()
	
	match resize_direction:
		ResizeDirection.HORIZONTAL:
			new_size.y = rect_size.y
		ResizeDirection.VERTICAL:
			new_size.x = rect_size.x
	
	set_size(new_size)
