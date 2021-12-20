tool

extends GraphEdit

enum PortType {
	UNIVERSAL,
	ACTION,
	FLOW
}

export(Array, Dictionary) var connection_list


func _enter_tree() -> void:
	add_valid_connection_type(PortType.UNIVERSAL, PortType.UNIVERSAL)
	add_valid_connection_type(PortType.UNIVERSAL, PortType.ACTION)
	add_valid_connection_type(PortType.UNIVERSAL, PortType.FLOW)
	
	add_valid_connection_type(PortType.ACTION, PortType.ACTION)
	add_valid_connection_type(PortType.ACTION, PortType.UNIVERSAL)
	
	add_valid_connection_type(PortType.FLOW, PortType.FLOW)
	add_valid_connection_type(PortType.FLOW, PortType.UNIVERSAL)
	
	add_valid_left_disconnect_type(PortType.FLOW)
	
	for conn in connection_list:
		connect_node(conn.from, conn.from_port, conn.to, conn.to_port)


func can_drop_data(_position: Vector2, data) -> bool:
	return data is Dictionary and data.get("value_type", "") == "GDComponent" 
	
	
func drop_data(position: Vector2, data : Dictionary) -> void:
	var gn : GraphNode = data.payload.instance()
	
	add_child(gn)
	
	gn.owner = self
	gn.offset = (scroll_offset + position) / zoom


func _on_connection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	if from == to:
		return

	var from_node : GraphNode = get_node(from)
	var total_local_slots := from_node.get_child_count()
	var from_mapped_slots := []
	
	for slot_local in range(total_local_slots):
		if from_node.is_slot_enabled_right(slot_local):
			from_mapped_slots.append(slot_local)
	
	var is_from_slot_port_flow = from_node\
			.get_slot_type_right(from_mapped_slots[from_slot]) == PortType.FLOW
	
	if is_from_slot_port_flow:
		var is_connected_to_another = GDUtil.array_dictionary_hasv(
				get_connection_list(), {"from": from, "from_port": from_slot})
		
		if is_connected_to_another:
			return
	
	
	connect_node(from, from_slot, to, to_slot)


func _on_disconnection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	disconnect_node(from, from_slot, to, to_slot)
