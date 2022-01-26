extends Resource

class_name DialogueCursor

export var s_flow : Array
export var s_index : int
export var s_port_table : Dictionary


func _init(graph_edit: GraphEdit) -> void:
	assert(graph_edit.has_method("connected_ports"))
	s_index = 0
	
	var connection_list = graph_edit.get_connection_list()
	var start = GDUtil.array_dictionary_popv(connection_list, [{"from": "Start"}])
	
	if start:
		s_flow.append(start)
		_populate_flow(start, connection_list, graph_edit)


func is_valid() -> bool:
	# exclude start connection
	return s_flow.size() > 1


func size() -> int:
	return s_flow.size()


func index() -> int:
	return s_index


func current() -> Dictionary:
	if s_flow.empty():
		return {}
	elif end():
		return s_flow[s_index - 1]
	else:
		return s_flow[s_index]


func front() -> Dictionary:
	return s_flow[0]


func back() -> Dictionary:
	return s_flow[size() - 1]


func end() -> bool:
	return s_index == size()
	

func goto(idx: int) -> void:
	s_index = clamp(idx, 0, size())

	
func next() -> void:
	s_index = min(s_index + 1, size())


func prev() -> void:
	s_index = max(s_index - 1, 0)
	
	
func _populate_flow(connection: Dictionary, connection_list: Array, dialogue_graph: GraphEdit, buffer := []) -> void:
	assert(dialogue_graph.has_method("connected_ports"))

	var current_ports : Dictionary = dialogue_graph.connected_ports(connection.from, connection_list)
	var next_ports : Dictionary = dialogue_graph.connected_ports(connection.to, connection_list)
	
	var forks : Array = GDUtil.array_dictionary_popallv(connection_list, next_ports.to.flow)
	
	s_port_table[connection.from] = current_ports
	
	if dialogue_graph.get_node(connection.to) is GNEnd:
		# There's a case where either the current connection is already inside the buffer,
		# or is not already inside it. By using erase, we make sure to always add one of them
		# for both scenario.
		buffer.erase(connection)
		
		s_flow.append(connection)
		s_flow.append_array(buffer)
		buffer.clear()
	if forks.empty():
		buffer.clear()
	else:
		buffer.append(forks.front())
	
	for flow in forks:
		_populate_flow(flow, connection_list, dialogue_graph, buffer)
	
	
