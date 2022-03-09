tool

extends Resource

class_name GDDialogueCursor

signal reset
signal end

enum {
	OK = OK,
	ERR_NO_FLOWPORT,
	ERR_NO_CONNECTION,
	ERR_END_REACHED
}


static func create(cursor: Resource = null):
	var script = load(GDUtil.resolve("GDDialogueCursor.gd"))
	
	if not cursor:
		return script.new()
	
	assert("root" in cursor, "cursor is not a valid GDDialogueCursor")
	assert("current" in cursor, "cursor is not a valid GDDialogueCursor")
	assert("pt" in cursor, "cursor is not a valid GDDialogueCursor")
	
	var instance = script.new(cursor.pt)
	instance.root = cursor.root
	instance.current = cursor.current
	
	return instance


export var root : String 
export var current : String 
export var pt : Resource 


func reset() -> void:
	current = root
	emit_signal("reset")


func end() -> void:
	current = ""
	print_debug("Ending cursor...")
	emit_signal("end")


func next(port : int) -> int:
	if current.empty():
		print_debug("Cursor end reached...")
		end()
		return ERR_END_REACHED
	
	var flow_ports := port_map().right_type_all_port(current, pt.PORT_FLOW)
	
	if flow_ports.empty():
		print_debug("%s has no flowport. Resetting..." % current)
		reset()
		return ERR_NO_FLOWPORT
	
	# use a correct port instead
	if not flow_ports.has(port):
		port = flow_ports.keys().front()
	
	# this port has no connection
	if flow_ports[port].empty():
		port = -1
		
		# find port that has connection
		for p in flow_ports:
			if not flow_ports[p].empty():
				port = p
		
		if port == -1:
			print_debug("%s has no output flowport connection. Resetting..." % current)
			reset()
			return ERR_NO_CONNECTION
	
	var nodes := port_map().right_type_port_connection(current, pt.PORT_FLOW, port).keys()
	current = nodes.front() if nodes.front() else ""
	
	return OK


func port_map() -> GDPortMap:
	return GDPortMap.create(pt)
