extends Resource

class_name GDDialogueCursor

signal prev
signal next
signal skipped

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
#export var s_port_table : Dictionary

export var pt : Resource = GDPortMap.new()


func _init(port_table := GDPortMap.new()) -> void:
	pt = port_table.copy()
	
	if pt.has_node("Start"):
		reset()


func get_node_name() -> String:
	return s_node_name


func reset() -> void:
	s_cursor = pt.get_table("Start")
	s_node_name = "Start"


func next_flow(port := -1) -> void:
	if port == -1:
		next(PortRect.PortType.FLOW)
	else:
		next_port(PortRect.PortType.FLOW, port)


func skip_flow(port := -1) -> void:
	next_flow(port)
	
	emit_signal("skipped")


func port_leftf() -> Array:
	return port_left(PortRect.PortType.FLOW)


func port_rightf() -> Array:
	return port_right(PortRect.PortType.FLOW)


func connection_leftf(port: int) -> Array:
	return connection_left(PortRect.PortType.FLOW, port)


func connection_rightf(port: int) -> Array:
	return connection_right(PortRect.PortType.FLOW, port)


func end() -> bool:
	return s_cursor.empty()


func port_left(port_type: int) -> Array:
	if end():
		return []
	
	return pt.node_connected_lport(get_node_name(), port_type)


func port_right(port_type: int) -> Array:
	if end():
		return []
	
	return pt.node_connected_rport(get_node_name(), port_type)


func connection_left(port_type: int, port: int) -> Array:
	if end():
		return []
	
	return pt.node_connection_left(get_node_name(), port_type, port)


func connection_right(port_type: int, port: int) -> Array:
	if end():
		return []
	
	return pt.node_connection_right(get_node_name(), port_type, port)


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
	
	var conn_list : Array = connection_right(port_type, port)
	
	if conn_list.empty():
		s_node_name = ""
	else:
		s_node_name = conn_list[idx].name

	s_cursor = pt.get_table(s_node_name)
	
	emit_signal("next")


func prev_port(port_type: int, port: int, idx := 0) -> void:
	if s_cursor.empty():
		return
	
	var conn_list : Array = connection_left(port_type, port)
	
	if conn_list.empty():
		s_node_name = ""
	else:
		s_node_name = conn_list[idx].name

	s_cursor = pt.get_table(s_node_name)
	
	emit_signal("prev")


func copy(copy_user_signal := false):
	# using load() as cyclic dependency workaround
	var ret = load(GDUtil.resolve("GDDialogueCursor.gd")).new(pt.port_table)
	ret.s_cursor = s_cursor.duplicate(true)
	ret.s_node_name = s_node_name

	if copy_user_signal:
		for signal_name in ["prev", "next", "flow_skipped"]:
			for connection in get_signal_connection_list(signal_name):
				ret.connect(connection.signal, connection.target, connection.method, connection.binds)
	
	return ret
