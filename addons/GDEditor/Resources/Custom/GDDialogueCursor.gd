extends Resource

class_name GDDialogueCursor

signal prev
signal next

export var s_cursor : Dictionary
export var s_node_name : String

# port_table dictionary:
# 	? = may or may not exist
#	
#	Structure:
#	-> node_name(String)?:
#		-> to(String):
#			-> PortType.UNIVERSAL(int)?:
#				-> left_port(int): [{node_name: String, node_left_port: int}, ...]
#				-> left_port(int)...
#			-> PortType.ACTION(int)?:
#				-> left_port(int): [{node_name: String, node_left_port: int}, ...]
#				-> left_port(int)...
#			-> PortType.FLOW(int)?:
#				-> left_port(int): [{node_name: String, node_left_port: int}, ...]
#				-> left_port(int)...
#		-> from(String):
#			-> PortType.UNIVERSAL(int)?:
#				-> right_port(int): [{node_name: String, node_right_port: int}, ...]
#				-> right_port(int)...
#			-> PortType.ACTION(int)?:
#				-> right_port(int): [{node_name: String, node_right_port: int}, ...]
#				-> right_port(int)...
#			-> PortType.FLOW(int)?:
#				-> right_port(int): [{node_name: String, node_right_port: int}, ...]
#				-> right_port(int)...
#	-> node_name(String)....
export var s_port_table : Dictionary


func _init(port_table: Dictionary) -> void:
	s_port_table = port_table.duplicate(true)
	
	if s_port_table.has("Start"):
		reset()


func get_node_name() -> String:
	return s_node_name


func reset() -> void:
	s_cursor = s_port_table["Start"]
	s_node_name = "Start"


func port_leftu() -> Array:
	return port_left(PortRect.PortType.UNIVERSAL)


func port_rightu() -> Array:
	return port_right(PortRect.PortType.UNIVERSAL)


func port_lefta() -> Array:
	return port_left(PortRect.PortType.ACTION)


func port_righta() -> Array:
	return port_right(PortRect.PortType.ACTION)


func port_leftf() -> Array:
	return port_left(PortRect.PortType.FLOW)


func port_rightf() -> Array:
	return port_right(PortRect.PortType.FLOW)


func connection_leftu(port: int) -> Array:
	return connection_left(PortRect.PortType.UNIVERSAL, port)


func connection_rightu(port: int) -> Array:
	return connection_right(PortRect.PortType.UNIVERSAL, port)


func connection_lefta(port: int) -> Array:
	return connection_left(PortRect.PortType.ACTION, port)


func connection_righta(port: int) -> Array:
	return connection_right(PortRect.PortType.ACTION, port)


func connection_leftf(port: int) -> Array:
	return connection_left(PortRect.PortType.FLOW, port)


func connection_rightf(port: int) -> Array:
	return connection_right(PortRect.PortType.FLOW, port)


func nextu(idx := 0) -> void:
	next(PortRect.PortType.UNIVERSAL, idx)


func nexta(idx := 0) -> void:
	next(PortRect.PortType.ACTION, idx)


func nextf(idx := 0) -> void:
	next(PortRect.PortType.FLOW, idx)


func prevu(idx := 0 ) -> void:
	prev(PortRect.PortType.UNIVERSAL, idx)


func preva(idx := 0) -> void:
	prev(PortRect.PortType.ACTION, idx)


func prevf(idx := 0) -> void:
	prev(PortRect.PortType.FLOW, idx)


func next_portu(port: int, idx := 0) -> void:
	next_port(PortRect.PortType.UNIVERSAL, port, idx)


func next_porta(port: int, idx := 0) -> void:
	next_port(PortRect.PortType.ACTION, port, idx)


func next_portf(port: int, idx := 0) -> void:
	next_port(PortRect.PortType.FLOW, port, idx)


func prev_portu(port: int, idx := 0) -> void:
	prev_port(PortRect.PortType.UNIVERSAL, port, idx)


func prev_porta(port: int, idx := 0) -> void:
	prev_port(PortRect.PortType.ACTION, port, idx)


func prev_portf(port: int, idx := 0) -> void:
	prev_port(PortRect.PortType.FLOW, port, idx)


func end() -> bool:
	return s_cursor.empty()


func port_left(port_type: int) -> Array:
	if end():
		return []
	
	if not s_cursor.from.has(port_type):
		return []
	
	var types : Dictionary = s_cursor.from[port_type]
	
	var ports := types.keys()
	ports.sort()
	
	return ports


func port_right(port_type: int) -> Array:
	if end():
		return []
	
	if not s_cursor.to.has(port_type):
		return []
	
	var types : Dictionary = s_cursor.to[port_type]

	var ports := types.keys()
	ports.sort()
	
	return ports


func connection_left(port_type: int, port: int) -> Array:
	if end():
		return []
	
	var port_types : Dictionary = s_cursor.from.get(port_type, {})
	
	return port_types.get(port, [])


func connection_right(port_type: int, port: int) -> Array:
	if end():
		return []
	
	var port_types : Dictionary = s_cursor.to.get(port_type, {})

	return port_types.get(port, [])


func next(port_type: int, idx := 0) -> void:
	var port_list := port_right(port_type)
	
	var port := 0
	
	if idx > -1 and idx < port_list.size():
		port = port_list[idx]
	
	next_port(port_type, port, idx)


func prev(port_type: int, idx := 0) -> void:
	var port_list := port_left(port_type)

	var port := 0

	if idx > -1 and idx < port_list.size():
		port = port_list[idx]

	prev_port(port_type, port, idx)


func next_port(port_type: int, port : int, idx := 0) -> void:
	if s_cursor.empty():
		return
	
	var port_list : Array = connection_right(port_type, port)
	
	if port_list.empty():
		s_node_name = ""
	else:
		s_node_name = port_list[idx].name

	s_cursor = s_port_table.get(s_node_name, {})
	
	emit_signal("next")


func prev_port(port_type: int, port: int, idx := 0) -> void:
	if s_cursor.empty():
		return
	
	var port_list : Array = connection_left(port_type, port)
	
	if port_list.empty():
		s_node_name = ""
	else:
		s_node_name = port_list[idx].name

	s_cursor = s_port_table.get(s_node_name, {})
	
	emit_signal("prev")
