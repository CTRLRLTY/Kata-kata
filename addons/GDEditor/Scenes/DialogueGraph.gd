tool

extends GraphEdit

enum PortType {
	UNIVERSAL,
	ACTION,
	FLOW
}

export(Array, Dictionary) var connection_list : Array

var popup_menu : PopupMenu

var _selected_nodes := []
var _copy_buffer := []


func _enter_tree() -> void:
	popup_menu = $DGPopupMenu


func _ready() -> void:
	popup_menu.connect("id_pressed", self, "_on_popup_menu_pressed")
	
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
	
	if gn is GNStart:
		for child in get_children():
			if child is GNStart:
				printerr("GraphEdit already has a StartNode")
				return
				
	elif gn is GNEnd:
		for child in get_children():
			if child is GNEnd:
				printerr("GraphEdit already has a EndNode")
				return
	
	add_child(gn)
	
	gn.owner = self
	gn.offset = (scroll_offset + position) / zoom


func save() -> void:
	var packer := PackedScene.new()
	popup_menu.owner = self
	
	connection_list = get_connection_list()
	packer.pack(self)
	
	ResourceSaver.save("res://test/test.tscn", packer)


func cursor() -> DialogueCursor:
	var ret := DialogueCursor.new(get_connection_list())


	return ret


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
				get_connection_list(), [{"from": from, "from_port": from_slot}])
		
		if is_connected_to_another:
			return
	
	
	connect_node(from, from_slot, to, to_slot)


func _on_disconnection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	disconnect_node(from, from_slot, to, to_slot)


func _on_popup_request(position: Vector2) -> void:
	popup_menu.set_size(Vector2.ZERO)
	popup_menu.set_position(position)
	
	if not _copy_buffer.empty():
		popup_menu.open_paste()
	elif not _selected_nodes.empty():
		popup_menu.open()


func _on_popup_menu_pressed(id: int) -> void:
	match id:
		popup_menu.Item.COPY:
			_copy_buffer = _selected_nodes.duplicate()
			
		popup_menu.Item.DELETE:
			for node in _selected_nodes:
				var node_connections = GDUtil.array_dictionary_findallv(get_connection_list(),
						[{"from": node.name}, {"to": node.name}])
				
				for connection in node_connections:
					disconnect_node(connection.from, 
							connection.from_port, connection.to, connection.to_port)
				
				node.queue_free()
			
			_selected_nodes.clear()


func _on_node_selected(node: Node) -> void:
	_selected_nodes.append(node)
	
	
func _on_node_unselected(node: Node) -> void:
	_selected_nodes.erase(node)
