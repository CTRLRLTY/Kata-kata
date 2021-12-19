tool

extends ReferenceRect

enum PortType {
	UNIVERSAL,
	ACTION,
	FLOW,
}

enum {
	NONE,
	INPUT,
	OUTPUT
}


export(PortType) var port_type := 0 setget set_port_type
export(bool) var enable := false setget set_enable


func _enter_tree() -> void:
	if get_tree().edited_scene_root == self:
		return
	
	_update_port()


func _get_configuration_warning() -> String:
	var parent := get_parent()
	
	if not parent:
		return "PortRect has to be a child of GraphNode"
	if parent is GraphNode:
		return "PortRect can't be a direct child of GraphNode"
	if not parent.get_parent() is GraphNode:
		return "PortRect has to be a grandcild of GraphNode"
	
	var position := get_position_in_parent()
	
	if position != 0 and position != parent.get_child_count() - 1:
		print_debug(position)
		return "PortRect has to either be the first or last child"
	
	return ""


func set_port_type(type : int) -> void:
	port_type = type
	_update_port()


func set_enable(p_enable : bool) -> void:
	enable = p_enable
	_update_port()
	
	
func _graph_owner() -> GraphNode:
	return get_parent().get_parent() as GraphNode


func _slot() -> int:
	return get_parent().get_position_in_parent()
	
	
func _connector_type() -> int:
	if get_position_in_parent() == 0:
		return INPUT
	else:
		return OUTPUT


func _update_port() -> void:
	if not is_inside_tree():
		return
		
	if not _get_configuration_warning().empty():
		return
	
	var gn := _graph_owner()
	var slot := _slot()
	
	match _connector_type():
		INPUT:
			gn.set_slot_enabled_left(slot, enable)
		OUTPUT:
			gn.set_slot_enabled_right(slot, enable)
	
#	gn.set_slot(slot, 
#			input_enable, port_type, Color(1, 1, 1), 
#			output_enable, port_type, Color(1, 1, 1))
		
#	# Clear up previous port from the editor.
#	gn.hide()
#	yield(get_tree(), "idle_frame")
#	gn.show()
	
		
		
		
		
		
		
		
