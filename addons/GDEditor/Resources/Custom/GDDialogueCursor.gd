extends Resource

class_name GDDialogueCursor

signal prev
signal next
signal skipped


static func create(cursor: Resource = null):
	var script = load(GDUtil.resolve("GDDialogueCursor.gd"))
	
	if not cursor:
		return script.new()
	
	assert("s_current" in cursor, "cursor is not a valid GDDialogueCursor")
	assert("s_pt" in cursor, "cursor is not a valid GDDialogueCursor")
	
	var instance = script.new(cursor.s_pt)
	instance.s_current = cursor.s_current
	
	return instance


export var s_current : String

export var s_pt : Resource 


func _init(port_table := GDPortMap.new()) -> void:
	s_pt = port_table.copy()
	
	if port_map().has_node("Start"):
		reset()


func current() -> String:
	return s_current


func reset() -> void:
	s_current = "Start"


func skip(port : int) -> void:
	next(port)
	emit_signal("skipped")


func next(port : int) -> void:
	if s_current.empty():
		return
	
	var flow_ports := port_map().right_type_all_port(s_current, s_pt.PORT_FLOW)
	assert(flow_ports.has(port), "%s has no flow port on slot %d" % [s_current, port])
	

	var nodes := port_map().right_type_port_connection(s_current, s_pt.PORT_FLOW, port).keys()
	s_current = nodes.front() if nodes.front() else ""
	
	emit_signal("next")


func port_map() -> GDPortMap:
	return GDPortMap.create(s_pt)


func is_end() -> bool:
	return s_current.empty()
