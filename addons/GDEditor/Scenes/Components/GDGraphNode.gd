tool

extends GraphNode

class_name GDGraphNode

enum {
	PORT_IN,
	PORT_OUT,
	PORT_INOUT
}


var _port_table : Dictionary
var _slot_table : Dictionary
var _slot_output_table : Dictionary


func _ready() -> void:
	_setup_port_slot()


func _setup_port_slot() -> void:
	_slot_table = {}
	_slot_output_table = {}
	_port_table = {}
	
	for section in get_children():
		var i : int = section.get_position_in_parent()
		
		if (is_slot_enabled_left(i) and is_slot_enabled_right(i)):
			var slot := _slot_table.size()
			
			_slot_table[slot] = {
				"port": i,
				"position": PORT_INOUT,
				"port_rect_in": section.get_child(0),
				"port_rect_out": section.get_child(section.get_child_count() - 1)
			} 
			
			_port_table[i] = _slot_table[slot].duplicate()
			_port_table[i].port = slot
			
			_slot_output_table[slot] = i
			
		elif is_slot_enabled_left(i):
			var slot := _slot_table.size()
			
			_slot_table[slot] = {
				"port": i,
				"position": PORT_IN,
				"port_rect_in": section.get_child(0),
			}
			
			_port_table[i] = _slot_table[slot].duplicate()
			_port_table[i].port = slot
			 
		elif is_slot_enabled_right(i):
			var slot := _slot_table.size()
			
			_slot_table[slot] = {
				"port": i,
				"position": PORT_OUT,
				"port_rect_out": section.get_child(section.get_child_count() - 1)
			}
			
			_port_table[i] = _slot_table[slot]
			_port_table[i].port = slot
			
			_slot_output_table[slot] = i


func slot2port(slot: int) -> int:
	return _slot_table[slot].port


func port2slot(port: int) -> int:
	return _port_table[port].port


func get_port_type_left(slot: int) -> int:
	return get_slot_type_left(_slot_table[slot].port)


func get_port_type_right(slot: int) -> int:
	return get_slot_type_right(_slot_table[slot].port)


func is_port_enable_left(slot: int) -> bool:
	return is_slot_enabled_left(_slot_table[slot].port)


func is_port_enable_right(slot: int) -> bool:
	return is_slot_enabled_right(_slot_table[slot].port)
