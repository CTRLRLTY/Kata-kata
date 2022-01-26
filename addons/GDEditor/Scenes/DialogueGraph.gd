tool

extends GraphEdit

class_name DialogueGraph

export(Array, Dictionary) var s_connection_list : Array

var popup_menu : PopupMenu

var _selected_nodes := []
var _copy_buffer := []
var _dialogue_cursor : DialogueCursor


func _enter_tree() -> void:
	popup_menu = $DGPopupMenu


func _ready() -> void:
	popup_menu.connect("id_pressed", self, "_on_popup_menu_pressed")
	
	add_valid_connection_type(PortRect.PortType.UNIVERSAL, PortRect.PortType.UNIVERSAL)
	add_valid_connection_type(PortRect.PortType.UNIVERSAL, PortRect.PortType.ACTION)
	add_valid_connection_type(PortRect.PortType.UNIVERSAL, PortRect.PortType.FLOW)
	
	add_valid_connection_type(PortRect.PortType.ACTION, PortRect.PortType.ACTION)
	add_valid_connection_type(PortRect.PortType.ACTION, PortRect.PortType.UNIVERSAL)
	
	add_valid_connection_type(PortRect.PortType.FLOW, PortRect.PortType.FLOW)
	add_valid_connection_type(PortRect.PortType.FLOW, PortRect.PortType.UNIVERSAL)
	
	add_valid_left_disconnect_type(PortRect.PortType.FLOW)
	add_valid_left_disconnect_type(PortRect.PortType.UNIVERSAL)
	
	for conn in s_connection_list:
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
	
	add_child(gn)
	
	gn.owner = self
	gn.offset = (scroll_offset + position) / zoom


func save() -> void:
	var packer := PackedScene.new()
	popup_menu.owner = self
	
	s_connection_list = get_connection_list()
	_dialogue_cursor = DialogueCursor.new(self)
	
	print_debug(_dialogue_cursor.s_flow)
	print_debug(_dialogue_cursor.s_port_table)
	
#	packer.pack(self)
#
#	ResourceSaver.save("res://test/test.tscn", packer)


func cursor() -> DialogueCursor:
	return _dialogue_cursor


func connected_ports(node_name: String, connection_list := get_connection_list()) -> Dictionary:
	var ret := {
		"from": {"universal": [], "flow": [], "action": []},
		"to": {"universal": [], "flow": [], "action": []}
	}
	
	var graph_node : GDGraphNode = get_node(node_name)
	var to_connection = GDUtil.array_dictionary_findallv(
			connection_list, [{"from": node_name}, {"to": node_name}])
	var from_connection = GDUtil.array_dictionary_popallv(to_connection, [{"to": node_name}])

	for connection in from_connection:
		var port_type := graph_node.get_port_type_left(connection.from_port)
		var port_key : String = PortRect.PortType.keys()[port_type].to_lower()
		ret["from"][port_key].append(connection)
	
	for connection in to_connection:
		var port_type := graph_node.get_port_type_right(connection.from_port)
		var port_key : String = PortRect.PortType.keys()[port_type].to_lower()
		ret["to"][port_key].append(connection)

	return ret


func _on_connection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	if from == to:
		return
	
	var from_node : GDGraphNode = get_node(from)
	
	
	match from_node.get_port_type_right(from_slot):
		PortRect.PortType.FLOW:
			continue
		PortRect.PortType.UNIVERSAL:
			continue
		_:
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
