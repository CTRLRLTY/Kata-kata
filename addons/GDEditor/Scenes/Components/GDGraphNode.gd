tool

extends GraphNode

class_name GDGraphNode

enum Port {
	LEFT,
	RIGHT
}


func get_component_name() -> String:
	return "GDGraphNode"


func get_dialogue_editor() -> Control:
	return GDUtil.get_dialogue_editor()


func get_port_type_left(slot: int) -> int:	
	return get_slot_type_left(slot2port(slot, Port.LEFT))


func get_port_type_right(slot: int) -> int:
	return get_slot_type_right(slot2port(slot, Port.RIGHT))


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


func is_port_enable_left(slot: int) -> bool:
	return is_slot_enabled_left(slot2port(slot, Port.LEFT))


func is_port_enable_right(slot: int) -> bool:
	return is_slot_enabled_right(slot2port(slot, Port.RIGHT))


func slot2port(slot: int, pos: int) -> int:
	assert(pos == Port.LEFT or pos == Port.RIGHT)
	
	var pos_string = Port.keys()[pos].to_lower()
	
	for idx in range(get_child_count()):
		if call("is_slot_enabled_%s" % pos_string, idx):
			if slot == 0:
				return idx
				
			slot = max(slot - 1, 0)
			
	return -1
