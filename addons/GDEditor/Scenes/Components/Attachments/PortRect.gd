tool

extends ReferenceRect

class_name PortRect

enum PortType {
	UNIVERSAL,
	ACTION,
	FLOW,
}

enum {
	INPUT,
	OUTPUT
}

export(PortType) var s_port_type := 0 setget set_port_type
export(bool) var s_port_enable := false setget set_port_enable


func _enter_tree() -> void:
	if get_tree().edited_scene_root == self:
		return
	
	_update_port()


func _ready() -> void:
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
	s_port_type = type
	_update_port()


func set_port_enable(p_enable : bool) -> void:
	s_port_enable = p_enable
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
	
	var port_color : Color
	
	match s_port_type:
		PortType.UNIVERSAL:
			port_color = Color.mediumaquamarine
		PortType.ACTION:
			port_color = Color.rebeccapurple
		PortType.FLOW:
			port_color = Color.forestgreen
	
	match _connector_type():
		INPUT:
			gn.set_slot(slot, 
					s_port_enable, s_port_type, port_color,
					gn.is_slot_enabled_right(slot), gn.get_slot_type_right(slot), gn.get_slot_color_right(slot))
		OUTPUT:
			gn.set_slot(slot, 
					gn.is_slot_enabled_left(slot), gn.get_slot_type_left(slot), gn.get_slot_color_left(slot),
					s_port_enable, s_port_type, port_color)
