tool

extends Resource

class_name GDDialogueCursor

signal prev
signal next
signal skipped


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


func skip(port : int) -> void:
	next(port)
	emit_signal("skipped")


func next(port : int) -> void:
	if current.empty():
		return
	
	var flow_ports := port_map().right_type_all_port(current, pt.PORT_FLOW)
	
	assert(not flow_ports.empty(), "%s has no flow port" % current)
	
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
		
		assert(port != -1, "%s has not output flow port connection")
	
	var nodes := port_map().right_type_port_connection(current, pt.PORT_FLOW, port).keys()
	current = nodes.front() if nodes.front() else ""
	
	emit_signal("next")


func port_map() -> GDPortMap:
	return GDPortMap.create(pt)


func is_end() -> bool:
	return current.empty()
