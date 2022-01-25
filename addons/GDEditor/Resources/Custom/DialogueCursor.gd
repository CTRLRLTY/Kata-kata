extends Resource

class_name DialogueCursor

export var s_connection_list : Array
export var s_flow : Array
export var s_index : int
export var s_is_valid : bool


func _init(connection_list : Array) -> void:
	s_connection_list = connection_list.duplicate()
	
	var start = GDUtil.array_dictionary_popv(connection_list, [{"from": "Start"}])
	
	if start:
		var next_queue := []
		next_queue.append_array(
				GDUtil.array_dictionary_popallv(connection_list, [{"from": start.to}]))
				
		print_debug(next_queue)
		
		var next = next_queue.pop_front()
				
		while next:
			print_debug(next)
			s_flow.append(next)
			
			next_queue.append_array(
				GDUtil.array_dictionary_popallv(connection_list, [{"from": next.to}]))

			next = next_queue.pop_front() 
			
		s_is_valid = GDUtil.array_dictionary_hasv(s_flow, [{"to": "End"}]) 
		
		print_debug("done")


func is_valid() -> bool:
	return s_is_valid


func size() -> void:
	pass


func current() -> Dictionary:
	return {}


func next() -> void:
	pass


func prev() -> void:
	pass
