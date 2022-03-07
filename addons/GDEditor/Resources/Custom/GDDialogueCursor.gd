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
	
	var previous = current
	
	var flow_ports := port_map().right_type_all_port(current, pt.PORT_FLOW)
	
	assert(not flow_ports.empty(), "%s has no flow port" % current)
	
	if not flow_ports.has(port):
		port = flow_ports.keys().front()
	
	var nodes := port_map().right_type_port_connection(current, pt.PORT_FLOW, port).keys()
	current = nodes.front() if nodes.front() else ""
	
	emit_signal("next")


func port_map() -> GDPortMap:
	return GDPortMap.create(pt)


func is_end() -> bool:
	return current.empty()
