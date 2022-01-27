tool

extends GraphNode

class_name GDGraphNode

enum {
	PORT_IN,
	PORT_OUT,
	PORT_INOUT
}

enum bic {}

var _slot_table : Dictionary


func _ready() -> void:
	_setup_port_slot()


func _setup_port_slot() -> void:
	_slot_table = {}
	
	for i in range(get_child_count()):
		if is_slot_enabled_left(i) and is_slot_enabled_right(i):
			_slot_table[_slot_table.size()] = {
				"port": i,
				"position": PORT_INOUT 
			} 
		if is_slot_enabled_left(i):
			_slot_table[_slot_table.size()] = {
				"port": i,
				"position": PORT_IN 
			} 
		elif is_slot_enabled_right(i):
			_slot_table[_slot_table.size()] = {
				"port": i,
				"position": PORT_OUT
			}


func get_port_type_left(slot: int) -> int:
	return get_slot_type_left(_slot_table[slot].port)



func get_port_type_right(slot: int) -> int:
	return get_slot_type_right(_slot_table[slot].port)


func is_port_enable_left(slot: int) -> bool:
	return is_slot_enabled_left(_slot_table[slot].port)


func is_port_enable_right(slot: int) -> bool:
	return is_slot_enabled_right(_slot_table[slot].port)


func _slot_table_append(port: int, position: int) -> void:
	assert(position >= PORT_IN and position <= PORT_INOUT, "position is not a valid port position")
	
	_slot_table[_slot_table.size() - 1] = {
		"port": port,
		"position": position
	}
