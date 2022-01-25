extends Resource

class_name GDialogue

export var s_dialogue_cursor : Resource
export var s_port_table : Dictionary
export var s_data_table : Dictionary


func _init(dialogue_graph: DialogueGraph) -> void:
	s_dialogue_cursor = dialogue_graph.cursor()
	
	var flow_buffer : Array = s_dialogue_cursor.s_flow.duplicate()
	
	while not flow_buffer.empty():
		var connection = flow_buffer.pop_front()
		
		s_port_table[connection["from"]] = {
			"flow": dialogue_graph.node_ports(connection["from"], PortRect.PortType.FLOW),
			"universal": dialogue_graph.node_ports(connection["from"], PortRect.PortType.UNIVERSAL),
			"action": dialogue_graph.node_ports(connection["from"], PortRect.PortType.ACTION)
		}
		
		var from_graph_node : GraphNode = dialogue_graph.get_node(connection["from"])
		var to_graph_node : GraphNode = dialogue_graph.get_node(connection["to"])
		
		# Setting up the data_table maybe be invoked multiple times for the same entry,
		# as they may be a case where the connection["from"] or connection["to"] of one node
		# is the same on another node.
		if from_graph_node.has_method("get_save_data"):
			s_data_table[connection["from"]] = from_graph_node.get_save_data()
			
		if to_graph_node.has_method("get_save_data"):
			s_data_table[connection["to"]] = to_graph_node.get_save_data()
		
		GDUtil.array_dictionary_popallv(flow_buffer, [{"from": connection["from"]}])


func size() -> int:
	return s_dialogue_cursor.size()


func current() -> Dictionary:
	if not s_dialogue_cursor.is_valid():
		return {}
	
	var connection : Dictionary = s_dialogue_cursor.current()
	
	if connection.empty():
		return {}
	
	return {"port": s_port_table[connection["from"]],
			"data": s_data_table[connection["from"]]}


func at(idx: int) -> Dictionary:
	var current_index : int = s_dialogue_cursor.index()

	s_dialogue_cursor.goto(idx)

	var ret = current()
	
	s_dialogue_cursor.goto(current_index)
	
	return ret


func goto(idx: int) -> void:
	s_dialogue_cursor.goto(idx)


func end() -> bool:
	return s_dialogue_cursor.end()


func next() -> void:
	s_dialogue_cursor.next()


func prev() -> void:
	s_dialogue_cursor.prev()
