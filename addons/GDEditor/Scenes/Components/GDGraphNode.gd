tool

extends GraphNode

class_name GDGraphNode


var _dialogue_editor : Control


func get_dialogue_editor() -> Control:
	return GDUtil.get_state("dialogue_editor")


func get_port_type_left(slot: int) -> int:
	return get_slot_type_left(slot2port(slot))


func get_port_type_right(slot: int) -> int:
	return get_slot_type_right(slot2port(slot))


func get_port_rects_left() -> Array:
	var port_rects := []
	for i in range(get_child_count()):
		if is_slot_enabled_left(i):
			var section : Control = get_child(i)
			var port_rect : PortRect = section.get_child(0)
			port_rects.append(port_rect)
	
	return port_rects


func get_port_rects_right() -> Array:
	var port_rects := []
	for i in range(get_child_count()):
		if is_slot_enabled_right(i):
			var section : Control = get_child(i)
			var port_rect : PortRect = section.get_child(section.get_child_count() - 1)
			port_rects.append(port_rect)
	
	return port_rects


func get_readers() -> Array:
	return []


func is_port_enable_left(slot: int) -> bool:
	return is_slot_enabled_left(slot2port(slot))


func is_port_enable_right(slot: int) -> bool:
	return is_slot_enabled_right(slot2port(slot))


func slot2port(slot: int) -> int:
	for i in range(get_child_count()):
		if is_slot_enabled_left(i) or is_slot_enabled_right(i):
			return i
	
	return -1
