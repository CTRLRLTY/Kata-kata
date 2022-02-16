tool

extends GraphNode

class_name GDGraphNode

enum Port {
	LEFT,
	RIGHT
}

enum PortType {
	UNIVERSAL = PortRect.PortType.UNIVERSAL,
	ACTION = PortRect.PortType.ACTION,
	FLOW = PortRect.PortType.FLOW,
}

var _dialogue_view : Control


func get_component_name() -> String:
	return "GDGraphNode"


func get_dialogue_editor() -> Control:
	return GDUtil.get_dialogue_editor()


func get_dialogue_graph() -> GraphEdit:
	return get_parent() as GraphEdit


func get_connections() -> Dictionary:
	return get_dialogue_graph().connected_ports(name)


func get_port_rects_left() -> Array:
	var port_rects := []
	for i in range(get_child_count()):
		if is_slot_enabled_left(i):
			var section : Control = get_child(i)
			var port_rect : PortRect = section.get_child(0)
			port_rects.append(port_rect)
	
	return port_rects


func get_dialogue_view() -> Control:
	return _dialogue_view


func set_dialogue_view(dialogue_view: Control) -> void:
	_dialogue_view = dialogue_view


func get_port_rects_right() -> Array:
	var port_rects := []
	
	for i in range(get_child_count()):
		if is_slot_enabled_right(i):
			var section : Control = get_child(i)
			var port_rect : PortRect = section.get_child(section.get_child_count() - 1)
			port_rects.append(port_rect)	
	return port_rects


func is_connection_connected_input(slot: int) -> bool:
	var dialogue_graph = get_dialogue_graph()
	
	if dialogue_graph:
		return dialogue_graph.is_node_left_connected(name, slot)
	
	return false


func is_connection_connected_output(slot: int) -> bool:
	var dialogue_graph = get_dialogue_graph()
	
	if dialogue_graph:
		return dialogue_graph.is_node_right_connected(name, slot)
	
	return false


func connect_from(graph_node: GDGraphNode, to_slot: int, from_slot: int) -> bool:
	return true


func connect_to(graph_node: GDGraphNode, from_slot: int, to_slot: int) -> bool:
	return true


func disconnect_from(graph_node: GDGraphNode, from_slot: int, to_slot: int) -> bool:
	return true


func disconnect_to(graph_node: GDGraphNode, to_slot: int, from_slot: int) -> bool:
	return true


func port2slot(slot: int, pos: int) -> int:
	assert(pos == Port.LEFT or pos == Port.RIGHT)
	
	var pos_string = Port.keys()[pos].to_lower()
	
	for idx in range(get_child_count()):
		if call("is_slot_enabled_%s" % pos_string, idx):
			if slot == 0:
				return idx
				
			slot = max(slot - 1, 0)
			
	return -1


func slot2port(port: int, pos: int) -> int:
	assert(pos == Port.LEFT or pos == Port.RIGHT)
	
	var pos_string = Port.keys()[pos].to_lower()
	var acc := 0
	
	for idx in range(get_child_count()):
		if call("is_slot_enabled_%s" % pos_string, idx):
			if port == 0:
				return acc
			
			acc += 1
				
		port = max(port - 1, 0)
			
	return -1
