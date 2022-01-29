tool

extends GraphNode

class_name GDGraphNode

enum {
	PORT_IN,
	PORT_OUT,
	PORT_INOUT
}

var _slots_in : Array
var _slots_out : Array
var _slots_rects_in : Array
var _slots_rects_out : Array


func _ready() -> void:
	_setup_port_slot()


func get_port_type_left(slot: int) -> int:
	return get_slot_type_left(_slots_in[slot])


func get_port_type_right(slot: int) -> int:
	return get_slot_type_right(_slots_out[slot])


func is_port_enable_left(slot: int) -> bool:
	return is_slot_enabled_left(_slots_in[slot])


func is_port_enable_right(slot: int) -> bool:
	return is_slot_enabled_right(_slots_out[slot])


func get_readers() -> Array:
	return []


func _setup_port_slot() -> void:
	_slots_in = []
	_slots_out = []
	
	_slots_rects_in = []
	_slots_rects_out = []
	
	for section in get_children():
		var i : int = section.get_position_in_parent()
		
		if is_slot_enabled_left(i):
			_slots_in.append(i)
			_slots_rects_in.append(section.get_child(0))
			 
		if is_slot_enabled_right(i):
			_slots_out.append(i)
			_slots_rects_out.append(section.get_child(section.get_child_count() - 1))
