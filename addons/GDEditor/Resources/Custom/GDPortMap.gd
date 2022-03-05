extends Resource

class_name GDPortMap

enum {
	PORT_FLOW
}

# _data dictionary:
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
export var _data : Dictionary


func _init(table := {}) -> void:
	_data = table


func get_table(node_name: String) -> Dictionary:
	return _data.get(node_name, {})


func has_node(node_name: String) -> bool:
	return _data.has(node_name)


func connect_node(from: String, from_type: int, from_slot: int, to: String, to_type: int, to_slot: int) -> void:
	var from_table : Dictionary = _data.get(from, {"to": {}, "from": {}})
	var to_table : Dictionary = _data.get(to, {"to": {}, "from": {}})
	
	from_table.to[from_type] = from_table.to.get(from_type, {})
	from_table.to[from_type][from_slot] = from_table.to[from_type].get(from_slot, [])
	
	to_table.from[to_type] = to_table.from.get(to_type, {})
	to_table.from[to_type][to_slot] = to_table.from[to_type].get(to_slot, [])
	
	var from_connlist : Array = from_table.to[from_type][from_slot]
	var to_connlist : Array = to_table.from[to_type][to_slot]
	
	from_connlist.append({"name": to, "port": to_slot})
	to_connlist.append({"name": from, "port": from_slot})
	
	_data[from] = from_table
	_data[to] = to_table


func disconnect_node(from: String, from_type: int, from_slot: int, to: String, to_type: int, to_slot: int) -> void:
	var from_connlist := node_connection_right(from, from_type, from_slot)
	var to_connlist := node_connection_left(to, to_type, to_slot)
	
	GDUtil.array_dictionary_popv(from_connlist, [{"name": to, "port": to_slot}])
	GDUtil.array_dictionary_popv(to_connlist, [{"name": from, "port": from_slot}])


func node_connected_ltypes(node_name: String) -> Array:
	return _data.get(node_name)["from"].keys()


func node_connected_rtypes(node_name: String) -> Array:
	return _data.get(node_name)["to"].keys()


func node_connected_lport(node_name: String, type: int) -> Array:
	var ports : Array = _data.get(node_name, {}).get("from", {}).get(type, {}).keys()
	ports.sort()
	
	return ports


func node_connected_rport(node_name: String, type: int) -> Array:
	var ports : Array = _data.get(node_name, {}).get("to", {}).get(type, {}).keys()
	ports.sort()
	
	return ports


func node_connection_left(node_name: String, type: int, port: int) -> Array:
	return _data.get(node_name, {}).get("from", {}).get(type, {}).get(port, [])


func node_connection_right(node_name: String, type: int, port: int) -> Array:
	return _data.get(node_name, {}).get("to", {}).get(type, {}).get(port, [])


func copy():
	var pt = load(GDUtil.resolve("GDPortMap.gd")).new(_data.duplicate(true))
	
	return pt
