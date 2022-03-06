extends Resource

class_name GDPortMap

enum {
	PORT_FLOW
}

# _tm dictionary:
# 	? = may or may not exist
#	
#	Structure:
#	-> node_name(String)?:
#		-> to(String)?:
#			-> port_type(int)?:
#				-> left_port(int):
#					-> node_name(String): [port(int), ...],
#					-> node_name(String)?...
#				-> left_port(int)...
#		-> from(String)?:
#			-> port_type(int)?:
#				-> left_port(int):
#					-> node_name(String): [port(int), ...],
#					-> node_name(String)?...
#				-> left_port(int)...
#	-> node_name(String)....
export var _tm : Dictionary

# _nm dictionary:
# 
#	Structure:
#	-> node_name(String)?:
#		-> 
export var _nm : Dictionary


func _init(table := {}) -> void:
	_tm = table


func get_table(node_name: String) -> Dictionary:
	return _tm.get(node_name, {})


func is_node_connected(from: String, from_type: int, from_slot: int, to: String, to_slot: int) -> bool:
	var connlist := node_connection_right(from, from_type, from_slot)
	
	var m : Array = connlist.get(to, [])
	
	return m.has(to_slot)


func has_node(node_name: String) -> bool:
	return _tm.has(node_name)


func connect_node(from: String, from_type: int, from_slot: int, to: String, to_type: int, to_slot: int) -> void:
	var from_table : Dictionary = _tm.get(from, {"to": {}, "from": {}})
	var to_table : Dictionary = _tm.get(to, {"to": {}, "from": {}})
	
	from_table.to[from_type] = from_table.to.get(from_type, {})
	from_table.to[from_type][from_slot] = from_table.to[from_type].get(from_slot, {})
	from_table.to[from_type][from_slot][to] = from_table.to[from_type][from_slot].get(to, [])
	
	to_table.from[to_type] = to_table.from.get(to_type, {})
	to_table.from[to_type][to_slot] = to_table.from[to_type].get(to_slot, {})
	to_table.from[to_type][to_slot][from] = to_table.from[to_type][from_slot].get(from, [])
	
	var fcn : Array = from_table.to[from_type][from_slot][to]
	var tcn : Array = to_table.from[to_type][to_slot][from]
	
	fcn.append(to_slot)
	tcn.append(from_slot)
	
	_tm[from] = from_table
	_tm[to] = to_table


func disconnect_node(from: String, from_type: int, from_slot: int, to: String, to_type: int, to_slot: int) -> void:
	var from_connlist := node_connection_right(from, from_type, from_slot)
	var to_connlist := node_connection_left(to, to_type, to_slot)
	
	var f : Array = from_connlist.get(to, [])
	var t : Array = to_connlist.get(from, [])
	
	f.erase(to_slot)
	t.erase(from_slot)
	
	if f.empty():
		from_connlist.erase(to)
	
	if t.empty():
		to_connlist.erase(from)


func node_connections(from: String, to: String):
	pass



func node_connected_ltypes(node_name: String) -> Array:
	return _tm.get(node_name)["from"].keys()


func node_connected_rtypes(node_name: String) -> Array:
	return _tm.get(node_name)["to"].keys()


func node_connected_lport(node_name: String, type: int) -> Array:
	var ports : Array = _tm.get(node_name, {}).get("from", {}).get(type, {}).keys()
	ports.sort()
	
	return ports


func node_connected_rport(node_name: String, type: int) -> Array:
	var ports : Array = _tm.get(node_name, {}).get("to", {}).get(type, {}).keys()
	ports.sort()
	
	return ports


func node_connection_left(node_name: String, type: int, port: int) -> Dictionary:
	return _tm.get(node_name, {}).get("from", {}).get(type, {}).get(port, {})


func node_connection_right(node_name: String, type: int, port: int) -> Dictionary:
	return _tm.get(node_name, {}).get("to", {}).get(type, {}).get(port, {})


func copy():
	var pt = load(GDUtil.resolve("GDPortMap.gd")).new(_tm.duplicate(true))
	
	return pt
