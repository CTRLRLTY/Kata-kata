extends Resource

class_name GDDialogueCursor

signal prev
signal next
signal skipped


static func create(cursor: Resource = null):
	var script = load(GDUtil.resolve("GDDialogueCursor.gd"))
	
	if not cursor:
		return script.new()
	
	assert("current" in cursor, "cursor is not a valid GDDialogueCursor")
	assert("pt" in cursor, "cursor is not a valid GDDialogueCursor")
	
	var instance = script.new(cursor.pt)
	instance.current = cursor.current
	
	return instance


export var current : String

export var pt : Resource 


func current() -> String:
	return current


func reset() -> void:
	current = "Start"


func skip(port : int) -> void:
	next(port)
	emit_signal("skipped")


func next(port : int) -> void:
	if current.empty():
		return
	
	var flow_ports := port_map().right_type_all_port(current, pt.PORT_FLOW)
	assert(flow_ports.has(port), "%s has no flow port on slot %d" % [current, port])
	

	var nodes := port_map().right_type_port_connection(current, pt.PORT_FLOW, port).keys()
	current = nodes.front() if nodes.front() else ""
	
	emit_signal("next")


func port_map() -> GDPortMap:
	return GDPortMap.create(pt)


func is_end() -> bool:
	return current.empty()
