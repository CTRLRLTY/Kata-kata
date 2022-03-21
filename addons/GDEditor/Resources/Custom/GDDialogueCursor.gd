tool

extends Resource

class_name GDDialogueCursor

signal reset
signal end
signal forwarded

enum {
	OK = OK,
	ERR_NO_FLOWPORT,
	ERR_NO_CONNECTION,
	ERR_NO_DEPTH,
	ERR_END_REACHED,
}


static func create(cursor: Resource = null):
	var script = load(GDutil.resolve("GDDialogueCursor.gd"))
	
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
export var pt : Resource = null


func reset() -> void:
	current = root
	emit_signal("reset")


func forward(port: int) -> void:
	if not next(port) == OK:
		return
	
	GDutil.print([self, " forwarding %s" % current], GDutil.PR_INFO, 3)
		
	emit_signal("forwarded")


func end() -> void:
	current = ""
	
	GDutil.print([self, " Ending cursor..."], GDutil.PR_INFO, 3)
	
	emit_signal("end")


func next(port : int) -> int:
	if current.empty():
		GDutil.print([self, " Cursor end reached..."], GDutil.PR_WARN, 1)
		
		end()
		return ERR_END_REACHED
	
	if port_map().get_node_depth(current) == 0:
		GDutil.print([self, " %s has zero depth. Resetting cursor..." % current], GDutil.PR_WARN, 1)
		
		reset()
		return ERR_NO_DEPTH
	
	var flow_ports := port_map().right_type_all_port(current, pt.PORT_FLOW)
	
	if flow_ports.empty():
		GDutil.print([self, " %s has no flowport. Resetting cursor..." % current], GDutil.PR_WARN, 1)
		
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
			GDutil.print([self, "%s has no output flowport connection. Resetting cursor..." % current], GDutil.PR_WARN, 2)
			
			reset()
			return ERR_NO_CONNECTION
	
	var nodes := port_map().right_type_port_connection(current, pt.PORT_FLOW, port).keys()
	var node_name: String = nodes.front() if nodes.front() else ""
	
	current = node_name
	
	return OK


func port_map() -> GDPortMap:
	return GDPortMap.create(pt)
