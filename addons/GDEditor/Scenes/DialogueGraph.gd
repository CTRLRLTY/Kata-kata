tool

extends GraphEdit

class_name DialogueGraph

signal graph_node_added(graph_node)

export(Array, Dictionary) var s_connection_list : Array

var _selected_nodes := []
var _copy_buffer := []
var _dialogue_cursor : GDDialogueCursor

onready var popup_menu: PopupMenu = $DGPopupMenu


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
	return data is Dictionary and data.get("value_type", "") == "GDGraphNodeScene" 


func drop_data(position: Vector2, data : Dictionary) -> void:
	var gn : GraphNode = data.payload.instance()
	
	if gn is GDStartGN:
		for child in get_children():
			if child is GDStartGN:
				printerr("GraphEdit already has a StartNode")
				return
	
	emit_signal("graph_node_added", gn)
	
	add_child(gn)
	
	gn.owner = self
	gn.offset = (scroll_offset + position) / zoom


func save() -> void:
	var packer := PackedScene.new()
	popup_menu.owner = self
	
	s_connection_list = get_connection_list()
	_dialogue_cursor = GDDialogueCursor.new(self)
	
	print_debug(_dialogue_cursor.s_port_table.keys())
#	packer.pack(self)
#
#	ResourceSaver.save("res://test/test.tscn", packer)
	
	
func cursor() -> GDDialogueCursor:
	if not _dialogue_cursor:
		_dialogue_cursor = GDDialogueCursor.new(self)
		
	return _dialogue_cursor


func connected_ports(node_name: String, connection_list := get_connection_list()) -> Dictionary:
	var ret := {
		"name": node_name,
		"from": {"universal": [], "flow": [], "action": []},
		"to": {"universal": [], "flow": [], "action": []}
	}
	
	var graph_node : GDGraphNode = get_node(node_name)
	var to_connection = GDUtil.array_dictionary_matchallv(
			connection_list, [{"from": node_name}, {"to": node_name}])
	var from_connection = GDUtil.array_dictionary_popallv(to_connection, [{"to": node_name}])

	for connection in from_connection:
		var port_type := graph_node.get_connection_input_type(connection.to_port)
		var port_key : String = PortRect.PortType.keys()[port_type].to_lower()
		ret["from"][port_key].append(connection)
	
	for connection in to_connection:
		var port_type := graph_node.get_connection_output_type(connection.from_port)
		var port_key : String = PortRect.PortType.keys()[port_type].to_lower()
		ret["to"][port_key].append(connection)

	return ret


func is_node_right_connected(node_name: String, slot: int) -> bool:
	return GDUtil.array_dictionary_hasv(
				get_connection_list(), [{"from": node_name, "from_port": slot}])


func is_node_left_connected(node_name: String, slot: int) -> bool:
	return GDUtil.array_dictionary_hasv(
			get_connection_list(), [{"to": node_name, "to_port": slot}])


func clear_node_connections(gn: GDGraphNode) -> void:
	var connections := GDUtil.array_dictionary_matchallv(get_connection_list(),
			[{"from": gn.name}, {"to": gn.name}])

	for connection in connections:
		disconnect_node(connection.from, connection.from_port, connection.to, connection.to_port)


func disconnect_node_input(node_name: String, port: int) -> void:
	var connections := GDUtil.array_dictionary_matchallv(get_connection_list(),
			[{"to": node_name, "to_port": port}])
	
	for connection in connections:
		disconnect_node(connection.from, connection.from_port, connection.to, connection.to_port)


func disconnect_node_output(node_name: String, port: int) -> void:
	var connections := GDUtil.array_dictionary_matchallv(get_connection_list(),
			[{"from": node_name, "from_port": port}])
	
	for connection in connections:
		disconnect_node(connection.from, connection.from_port, connection.to, connection.to_port)


func _on_connection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	if from == to:
		return
	
	var from_node : GDGraphNode = get_node(from)
	var to_node : GDGraphNode = get_node(to)

	var from_port_type := from_node.get_connection_output_type(from_slot)
	var to_port_type := to_node.get_connection_input_type(to_slot)
	
	# One to many connection check
	match from_port_type:
		PortRect.PortType.FLOW:
			continue
		PortRect.PortType.UNIVERSAL:
			continue
		_:
			if is_node_right_connected(from, from_slot):
				return
	
	if not from_node.connect_to(to_node, to_slot, from_slot) or \
	   not to_node.connect_from(from_node, from_slot, to_slot)\
	:
		return
	
	connect_node(from, from_slot, to, to_slot)


func _on_disconnection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	var from_node : GDGraphNode = get_node(from)
	var to_node : GDGraphNode = get_node(to)
	
	if not from_node.disconnect_to(to_node, to_slot, from_slot) or \
	   not to_node.disconnect_from(from_node, from_slot, to_slot)\
	:
		return
	
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
				clear_node_connections(node)
				
				node.queue_free()
			
			_selected_nodes.clear()


func _on_node_selected(node: Node) -> void:
	_selected_nodes.append(node)
	
	
func _on_node_unselected(node: Node) -> void:
	_selected_nodes.erase(node)
