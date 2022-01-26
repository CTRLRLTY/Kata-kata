tool

extends GraphNode

class_name GDGraphNode

enum {
	PORT_LEFT,
	PORT_RIGHT
}

var _port_slots : Array


func _ready() -> void:
	_setup_port_slots()


func _setup_port_slots() -> void:
	_port_slots = []
	
	for i in range(get_child_count()):
		if is_slot_enabled_left(i) or is_slot_enabled_right(i):
			_port_slots.append(i)


func get_port_type_left(slot: int) -> int:
	return get_slot_type_left(_port_slots[slot])
	

func get_port_type_right(slot: int) -> int:
	return get_slot_type_right(_port_slots[slot])


func is_port_enable_left(slot: int) -> bool:
	return is_slot_enabled_left(_port_slots[slot])


func is_port_enable_right(slot: int) -> bool:
	return is_slot_enabled_right(_port_slots[slot])
