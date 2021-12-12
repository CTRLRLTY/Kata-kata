extends Resource

class_name ComponentData

export var connections : Array
export var state : Dictionary

func _init() -> void:
	set_meta("value_type", GDUtil.COMPONENT_DATA)
