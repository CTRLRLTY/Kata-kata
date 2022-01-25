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
		
		var graph_node : GraphNode = dialogue_graph.get_node(connection["from"])
		
		if graph_node.has_method("get_save_data"):
			s_data_table[connection["from"]] = graph_node.get_save_data()
		
		GDUtil.array_dictionary_popallv(flow_buffer, [{"from": connection["from"]}])
