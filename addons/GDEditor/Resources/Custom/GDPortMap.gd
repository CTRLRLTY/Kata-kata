extends Resource

class_name GDPortMap

enum {
	PORT_FLOW
}

signal connected(from, from_slot, to, to_slot)
signal disconnected(from, from_slot, to, to_slot)


static func create(pm : Resource = null):
	var script = load(GDUtil.resolve("GDPortMap.gd"))
	
	if not pm:
		return script.new()
	
	assert("_tm" in pm, "pm is not a valid port_map resource")
	assert(pm._tm is Dictionary, "pm is not a valid port_map resource")	
	
	return script.new(pm._tm)

# _tm dictionary:
# 	? = may or may not exist
#	
#	Structure:
#	-> node_name(String)?:
#		-> to(String)?:
#			-> port_type(int)?:
#				-> port(int):
#					-> node_name(String): [port(int), ...],
#					-> node_name(String)?...
#				-> port(int)...
#			-> port_type(int)...
#		-> from(String)?:
#			-> port_type(int)?:
#				-> port(int):
#					-> node_name(String): [port(int), ...],
#					-> node_name(String)?...
#				-> port(int)...
#			-> port_type(int)...
#	-> node_name(String)....
export var _tm : Dictionary


func _init(table := {}) -> void:
	_tm = table


func has_connection_port(from: String, from_slot: int, to: String, to_slot: int) -> bool:
	var ap := right_all_port(from)
	
	if not ap.has(from_slot):
		return false
	
	if not ap[from_slot].has(to):
		return false

	return true


func has_connection(from: String, to: String) -> bool:
	var ap := right_all_port(from)
	
	for port in ap:
		if ap[port].has(to):
			return true
	
	return false


func has_node(node_name: String) -> bool:
	return _tm.has(node_name)


func clear_connection(node_name: String) -> void:
	var lp := left_all_port(node_name)
	var rp := right_all_port(node_name)
	
	for port in lp:
		left_disconnect(node_name, port)
	
	for port in rp:
		right_disconnect(node_name, port)


func connect_node(from: String, from_type: int, from_slot: int, to: String, to_type: int, to_slot: int) -> void:
	var from_table : Dictionary = _tm.get(from, {"to": {}, "from": {}})
	var to_table : Dictionary = _tm.get(to, {"to": {}, "from": {}})
	
	from_table.to[from_type] = from_table.to.get(from_type, {})
	from_table.to[from_type][from_slot] = from_table.to[from_type].get(from_slot, {})
	from_table.to[from_type][from_slot][to] = from_table.to[from_type][from_slot].get(to, [])
	
	to_table.from[to_type] = to_table.from.get(to_type, {})
	to_table.from[to_type][to_slot] = to_table.from[to_type].get(to_slot, {})
	to_table.from[to_type][to_slot][from] = to_table.from[to_type][to_slot].get(from, [])
	
	var fcn : Array = from_table.to[from_type][from_slot][to]
	var tcn : Array = to_table.from[to_type][to_slot][from]
	
	fcn.append(to_slot)
	tcn.append(from_slot)
	
	_tm[from] = from_table
	_tm[to] = to_table
	
	emit_signal("connected", from, from_slot, to, to_slot)


func disconnect_node(from: String, from_slot: int, to: String, to_slot: int) -> void:
	var from_connlist := right_port_connection(from, from_slot)
	var to_connlist := left_port_connection(to, to_slot)

	var f : Array = from_connlist.get(to, [])
	var t : Array = to_connlist.get(from, [])

	f.erase(to_slot)
	t.erase(from_slot)

	if f.empty():
		from_connlist.erase(to)

	if t.empty():
		to_connlist.erase(from)

	emit_signal("disconnected", from, from_slot, to, to_slot)


func left_type_port_connection(node_name: String, type: int, port: int) -> Dictionary:
	return left_type_all_port(node_name, type).get(port, {})


func right_type_port_connection(node_name: String, type: int, port: int) -> Dictionary:
	return right_type_all_port(node_name, type).get(port, {})


func left_type_all_port(node_name: String, type: int) -> Dictionary:
	return left_all_type(node_name).get(type, {})


func right_type_all_port(node_name: String, type: int) -> Dictionary:
	return right_all_type(node_name).get(type, {})


func left_port_connection(node_name: String, port: int) -> Dictionary:
	return left_all_port(node_name).get(port, {})


func right_port_connection(node_name: String, port: int) -> Dictionary:
	return right_all_port(node_name).get(port, {})


func left_all_port(node_name: String) -> Dictionary:
	var all_port := {}
	
	var at := left_all_type(node_name)
	
	for type in at:
		for port in at[type]:
			all_port[port] = at[type][port]
	
	return all_port


func right_all_port(node_name: String) -> Dictionary:
	var all_port := {}
	
	var at := right_all_type(node_name)
	
	for type in at:
		for port in at[type]:
			all_port[port] = at[type][port]
	
	return all_port


func left_all_type(node_name: String) -> Dictionary:
	return _tm.get(node_name, {}).get("from", {})


func right_all_type(node_name: String) -> Dictionary:
	return _tm.get(node_name, {}).get("to", {})


func left_disconnect(node_name: String, left_port: int) -> void:
	var ap := left_all_port(node_name)
	
	for other_node in ap[left_port]:
		for right_port in ap[left_port][other_node]:
			disconnect_node(other_node, right_port, node_name, left_port)


func right_disconnect(node_name: String, right_port: int) -> void:
	var ap := right_all_port(node_name)
	
	for other_node in ap[right_port]:
		for left_port in ap[right_port][other_node]:
			disconnect_node(node_name, right_port, other_node, left_port)


func left_connected(node_name: String, left_port: int) -> bool:
	var ap := left_all_port(node_name)
	
	return not ap.get(left_port, {}).empty()


func right_connected(node_name: String, right_port: int) -> bool:
	var ap := right_all_port(node_name)
	
	return not ap.get(right_port, {}).empty()


func copy():
	var pt = load(GDUtil.resolve("GDPortMap.gd")).new(_tm.duplicate(true))
	
	return pt
