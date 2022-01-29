extends Resource

class_name DialogueCursor

export var s_flow : Array
export var s_cursor : Dictionary
export var s_start : Dictionary
export var s_end : Array
export var s_port_table : Dictionary

var _prev : Dictionary


func _init(graph_edit: GraphEdit) -> void:
	assert(graph_edit.has_method("connected_ports"))
	
	var connection_list = graph_edit.get_connection_list()
	var start = GDUtil.array_dictionary_popv(connection_list, [{"from": "Start"}])
	
	if start:
		s_start = start
		_populate_flow(start, connection_list, graph_edit)
	
		s_cursor = start()


func size() -> int:
	return s_flow.size()


func reset() -> void:
	s_cursor = start()


func current() -> Dictionary:
	return s_cursor


func start() -> Dictionary:
	return s_port_table.get("Start", {}) 


func end() -> Array:
	return s_end


func is_end() -> bool:
	return s_cursor.empty()


func is_start() -> bool:
	return s_cursor == start() or s_start.empty()


func is_invalid() -> bool:
	return is_end() and is_start() 


func next(fork := 0) -> void:
	if is_end():
		return
	
	_prev = s_cursor
		
	fork = clamp(fork, 0, s_cursor.to.flow.size() - 1)
	var connection = s_cursor.to.flow[fork]

	s_cursor = s_port_table.get(connection.to, {})


func prev(fork := -777) -> void:
	if is_start():
		return
	
	if fork == -777:
		s_cursor = _prev
	else:
		fork = clamp(fork, 0, s_cursor.from.flow.size() - 1)
		var connection = s_cursor.from.flow[fork]

		s_cursor = s_port_table.get(connection.from, start())
	
	
func _populate_flow(connection: Dictionary, connection_list: Array, dialogue_graph: GraphEdit, buffer := []) -> void:
	assert(dialogue_graph.has_method("connected_ports"))

	var current_ports : Dictionary = dialogue_graph.connected_ports(connection.from)
	var next_ports : Dictionary = dialogue_graph.connected_ports(connection.to, connection_list)
	
	s_port_table[connection.from] = current_ports
	# If a universal from_port is connected to a flow to_port, then also add it to the flow["to"] array
	for _connection in next_ports["to"]["universal"]:
		var to_graph_node : GDGraphNode = dialogue_graph.get_node(_connection["to"])
		var to_port_type := to_graph_node.get_port_type_left(_connection["to_port"])
		if  to_port_type == PortRect.PortType.FLOW:
			next_ports["to"]["flow"].append(_connection)
	
	var forks : Array = GDUtil.array_dictionary_popallv(connection_list, next_ports.to.flow)
	
	if dialogue_graph.get_node(connection.to) is GNEnd:
		# There's a case where either the current connection is already inside the buffer,
		# or is not already inside it. By using erase, we make sure to always add one of them
		# for both scenario.
		buffer.erase(connection)
		s_end.append(connection)
		s_flow.append(connection)
		s_flow.append_array(buffer)
		buffer.clear()
	if forks.empty():
		buffer.clear()
	else:
		buffer.append(forks.front())
	
	for flow in forks:
		_populate_flow(flow, connection_list, dialogue_graph, buffer)
	
	
