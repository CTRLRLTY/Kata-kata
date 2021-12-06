tool

extends ReferenceRect

enum PortType {
	UNIVERSAL,
	ACTION,
	FLOW,
}

enum ConnectorType {
	NONE,
	INPUT,
	OUTPUT,
}

export(PortType) var port_type := 0 setget set_port_type
export(ConnectorType) var connector_type := 0 setget set_connector_type

func _enter_tree() -> void:
	if get_tree().edited_scene_root == self:
		return
	
	_update_port()
	
	
func get_graph_owner() -> GraphNode:
	var parent := get_parent()
	assert(parent, "PortRect can't be a direct child of GraphNode")
	var grand_parent := parent.get_parent()
	assert(grand_parent is GraphNode, "PortRect has to be a grandchild of GraphNode")
	
	return grand_parent as GraphNode
	
	
func get_slot() -> int:
	var parent := get_parent()
	assert(parent, "PortRect can't be a direct child of GraphNode")
	
	return parent.get_position_in_parent()
	
	
func set_port_type(type : int) -> void:
	port_type = type
	_update_port()
	
	
func set_connector_type(type : int) -> void:
	connector_type = type
	_update_port()
	

func _update_port() -> void:
	if not is_inside_tree():
		return
	
	var gn := get_graph_owner()
	
	if not gn:
		return
		
	var slot := get_slot()
	var input_enable := false
	var output_enable := false
	
	match connector_type:
		ConnectorType.INPUT:
			if gn.is_slot_enabled_left(slot):
				set_connector_type(0)
				return
				
			input_enable = true
			output_enable = gn.is_slot_enabled_right(slot)
		ConnectorType.OUTPUT:
			if gn.is_slot_enabled_right(slot):
				set_connector_type(0)
				return
				
			input_enable = gn.is_slot_enabled_left(slot)
			output_enable = true

	gn.set_slot(slot, 
		input_enable, port_type, Color(1, 1, 1), 
		output_enable, port_type, Color(1, 1, 1))
		
	# Clear up previous port from the editor.
	gn.hide()
	yield(get_tree(), "idle_frame")
	gn.show()
	
		
		
		
		
		
		
		
