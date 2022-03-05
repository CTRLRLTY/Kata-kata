tool

extends GraphNode

class_name GDGraphNode

signal branch_updated

enum Port {
	LEFT,
	RIGHT
}

enum PortType {
	ANY = -1
	FLOW = GDPortMap.PORT_FLOW
}

var _dialogue_view : Control
var _graph_editor : Control

var _branch_index := 0


func _ready() -> void:
	if not has_meta("branch_index"):
		set_meta("branch_index", _branch_index)
	
	set_branch_index(get_meta("branch_index"))


func get_branch_index() -> int:
	return _branch_index


func set_branch_index(num: int) -> void:
	var bare_title = title.trim_suffix("[%d]" % _branch_index)
	
	title = bare_title + "[%d]" % num
	
	_branch_index = num
	set_meta("branch_index", num)
	
	emit_signal("branch_updated")


func get_dialogue_view() -> Control:
	return _dialogue_view


func set_dialogue_view(dialogue_view: Control) -> void:
	_dialogue_view = dialogue_view


func get_graph_editor() -> Control:
	return _graph_editor


func set_graph_editor(ge: Control) -> void:
	_graph_editor = ge


func get_component_name() -> String:
	return "GDGraphNode"


func get_readers() -> Array:
	return []


func get_dialogue_editor() -> Control:
	return GDUtil.get_dialogue_editor()


func get_dialogue_graph() -> GraphEdit:
	return get_parent() as GraphEdit


func get_connections() -> Dictionary:
	return get_dialogue_graph().s_port_table.get(name)


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


func disconnect_input(slot: int) -> void:
	if is_connection_connected_input(slot):
		get_dialogue_graph().disconnect_node_input(name, slot)


func disconnect_output(slot: int) -> void:
	if is_connection_connected_output(slot):
		get_dialogue_graph().disconnect_node_output(name, slot)


func disconnect_all_ports() -> void:
	if get_dialogue_graph():
		get_dialogue_graph().clear_node_connections(self)


func get_ports(port_type: int, pos: int) -> Array:
	assert(pos == Port.LEFT or pos == Port.RIGHT)
	
	var ports := []
	
	var pos_string : String = Port.keys()[pos].to_lower()
	var f_enable := "is_slot_enabled_%s" % pos_string
	var f_type := "get_slot_type_%s" % pos_string
	
	var port_count := 0
	
	for child in get_children():
		var idx : int = child.get_index()
		
		if call(f_enable, idx):
			match port_type:
				PortType.ANY:
					ports.append(port_count)
				_:
					if call(f_type, idx) == port_type:
						ports.append(port_count)
			
			port_count += 1
	
	return ports


func slot2port(slot: int, pos: int) -> int:
	assert(pos == Port.LEFT or pos == Port.RIGHT)
	
	var pos_string = Port.keys()[pos].to_lower()
	
	for idx in range(get_child_count()):
		if call("is_slot_enabled_%s" % pos_string, idx):
			if slot == 0:
				return idx
				
			slot = max(slot - 1, 0)
			
	return -1


func port2slot(port: int, pos: int) -> int:
	assert(pos == Port.LEFT or pos == Port.RIGHT)
	
	var pos_string = Port.keys()[pos].to_lower()
	var acc := 0
	
	for idx in range(get_child_count()):
		if call("is_slot_enabled_%s" % pos_string, idx):
			if port == 0:
				return acc - 1
			
			acc += 1
				
		port = max(port - 1, 0)
			
	return -1


func get_save_data():
	pass
