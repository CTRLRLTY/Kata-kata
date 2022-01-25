extends Resource

class_name DialogueCursor

export var s_connection_list : Array
export var s_flow : Array
export var s_index : int
export var s_is_valid : bool


func _init(connection_list : Array) -> void:
	s_connection_list = connection_list
	s_index = 0
	
	connection_list = connection_list.duplicate()
	
	var start = GDUtil.array_dictionary_popv(connection_list, [{"from": "Start"}])
	
	if start:
		var next_queue := []
		next_queue.append_array(
				GDUtil.array_dictionary_popallv(connection_list, [{"from": start.to}]))
		
		var next = next_queue.pop_front()
				
		while next:
			s_flow.append(next)
			
			next_queue.append_array(
				GDUtil.array_dictionary_popallv(connection_list, [{"from": next.to}]))

			next = next_queue.pop_front() 
			
		s_is_valid = GDUtil.array_dictionary_hasv(s_flow, [{"to": "End"}]) 


func is_valid() -> bool:
	return s_is_valid


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


func end() -> bool:
	return s_index == size()


func next() -> void:
	s_index = min(s_index + 1, size())


func prev() -> void:
	s_index = max(s_index - 1, 0)
