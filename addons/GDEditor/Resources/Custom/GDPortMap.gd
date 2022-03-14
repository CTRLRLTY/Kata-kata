tool

extends Resource

class_name GDPortMap

enum {
	PORT_FLOW
}

signal connected(from, from_slot, to, to_slot)
signal disconnected(from, from_slot, to, to_slot)
signal depth_set(node_name, depth)


static func create(pm : Resource = null):
	var script = load(GDutil.resolve("GDPortMap.gd"))
	
	if not pm:
		return script.new()
	
	assert("depth" in pm, "pm is not a valid port_map resource")
	assert("table" in pm, "pm is not a valid port_map resource")
	assert(pm.table is Dictionary, "pm is not a valid port_map resource")	
	
	var port_map = script.new()
	
	var table : Dictionary = pm.table
	var depth : Dictionary = pm.depth
	
	port_map.table = pm.table
	port_map.depth = pm.depth
	
	return port_map

# table dictionary:
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
export var table : Dictionary

# node_name -> node_depth
export var depth : Dictionary


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


func is_linked_from(node_name: String, from: String) -> bool:
	var fap := left_type_all_port(node_name, PORT_FLOW)
	
	for port in fap:
		var conn : Dictionary = fap[port]
		
		if conn.has(from):
			return true
	
		for ffrom in conn:
			if is_linked_from(ffrom, from):
				return true

	return false


func has_node(node_name: String) -> bool:
	return table.has(node_name)


func clear_connection(node_name: String) -> void:
	# Their order of disconnection is important, as it effect how depth are modified.
	# 	It should be disconnected right then left in that order respectively.
	clear_right(node_name)
	clear_left(node_name)


func clear_left(node_name: String) -> void:
	var ap := left_all_port(node_name)
	
	for port in ap:
		left_disconnect(node_name, port)


func clear_right(node_name: String) -> void:
	var ap := right_all_port(node_name)
	
	for port in ap:
		right_disconnect(node_name, port)


func connect_node(from: String, from_type: int, from_slot: int, to: String, to_type: int, to_slot: int) -> void:
	var from_table : Dictionary = table.get(from, {"to": {}, "from": {}})
	var to_table : Dictionary = table.get(to, {"to": {}, "from": {}})
	
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
	
	table[from] = from_table
	table[to] = to_table
	
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


# Return value -> {
#	port(int): {
#			node_name(String): [port(int), ...],
#			node_name(String)?...
#		},
#	port(int)...
# }
func left_type_all_port(node_name: String, type: int) -> Dictionary:
	return left_all_type(node_name).get(type, {})


# Return value -> {
#	port(int): {
#			node_name(String): [port(int), ...],
#			node_name(String)?...
#		},
#	port(int)...
# }
func right_type_all_port(node_name: String, type: int) -> Dictionary:
	return right_all_type(node_name).get(type, {})


func left_port_connection(node_name: String, port: int) -> Dictionary:
	return left_all_port(node_name).get(port, {})


func right_port_connection(node_name: String, port: int) -> Dictionary:
	return right_all_port(node_name).get(port, {})


# Return value -> {
#	port(int): {
#			node_name(String): [port(int), ...],
#			node_name(String)?...
#		},
#	port(int)...
# }
func left_all_port(node_name: String) -> Dictionary:
	var all_port := {}
	
	var at := left_all_type(node_name)
	
	for type in at:
		for port in at[type]:
			all_port[port] = at[type][port]
	
	return all_port


# Return value -> {
#	port(int): {
#			node_name(String): [port(int), ...],
#			node_name(String)?...
#		},
#	port(int)...
# }
func right_all_port(node_name: String) -> Dictionary:
	var all_port := {}
	
	var at := right_all_type(node_name)
	
	for type in at:
		for port in at[type]:
			all_port[port] = at[type][port]
	
	return all_port


func left_all_type(node_name: String) -> Dictionary:
	return table.get(node_name, {}).get("from", {})


func right_all_type(node_name: String) -> Dictionary:
	return table.get(node_name, {}).get("to", {})


func left_disconnect(node_name: String, left_port: int) -> void:
	var ap := left_all_port(node_name)
	
	for other_node in ap.get(left_port, {}):
		for right_port in ap[left_port][other_node]:
			disconnect_node(other_node, right_port, node_name, left_port)


func left_disconnect_type_all(node_name: String, type: int) -> void:
	var ap := left_type_all_port(node_name, type)
	
	for port in ap:
		for to_node in ap[port].duplicate(true):
			for to_port in ap[port][to_node]:
				disconnect_node(to_node, to_port, node_name, port)


func right_disconnect(node_name: String, right_port: int) -> void:
	var ap := right_all_port(node_name)
	
	for other_node in ap.get(right_port, {}):
		for left_port in ap[right_port][other_node]:
			disconnect_node(node_name, right_port, other_node, left_port)


func right_disconnect_type_all(node_name: String, type: int) -> void:
	var ap := right_type_all_port(node_name, type)
	
	for port in ap:
		for to_node in ap[port].duplicate(true):
			for to_port in ap[port][to_node]:
				disconnect_node(node_name, port, to_node, to_port)
				

func left_connected(node_name: String, left_port: int) -> bool:
	var ap := left_all_port(node_name)
	
	return not ap.get(left_port, {}).empty()


func right_connected(node_name: String, right_port: int) -> bool:
	var ap := right_all_port(node_name)
	
	return not ap.get(right_port, {}).empty()


func left_connected_to(from: String, from_port: int, to: String) -> bool:
	var ap := left_all_port(from)
	
	return ap.get(from_port, {}).has(to)


func right_connected_to(from: String, from_port: int, to: String) -> bool:
	var ap := right_all_port(from)
	
	return ap.get(from_port, {}).has(to)


func copy():
	var pt = load(GDutil.resolve("GDPortMap.gd")).new()
	pt.table = table.duplicate(true)
	
	return pt


func set_node_depth(node_name: String, depth: int) -> void:
	self.depth[node_name] = depth
	
	emit_signal("depth_set", node_name, depth)


func get_node_depth(node_name: String) -> int:
	return depth.get(node_name, 0)


func update_depth_chain(node_name: String, depth: int, next_depth := 0, head := true) -> void:
	var current_depth := get_node_depth(node_name)
	var fap := left_type_all_port(node_name, PORT_FLOW)
	
	var d : int
	
	if head:
		d = depth
		head = false
	else:
		d = current_depth + depth - next_depth
	
	
	for port in fap:
		var conn : Dictionary = fap[port]
	
		for from in conn:
			update_depth_chain(from, d, current_depth, head)
	
	
	set_node_depth(node_name, d)

