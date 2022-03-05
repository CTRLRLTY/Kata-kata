tool

extends GraphEdit

class_name DialogueGraph

signal graph_node_added(graph_node)

export var s_connection_list : Array

export var pt : Resource = GDPortMap.new()

var _selected_nodes := []
var _copy_buffer := []

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


func disconnect_node(from: String, from_port: int, to: String, to_port: int) -> void:
	var from_node : GDGraphNode = get_node(from)
	var to_node : GDGraphNode = get_node(to)
	
	var from_type : int = from_node.get_connection_output_type(from_port)
	var to_type : int = to_node.get_connection_input_type(to_port)
	
	to_node.set_branch_index(0)
	
	pt.disconnect_node(from, from_type, from_port, to, to_type, to_port)
	
	if from_type == from_node.PortType.FLOW:
		if from_node.is_connected("branch_updated", self, "_chain_branch_update"):
			from_node.disconnect("branch_updated", self, "_chain_branch_update")
	
	.disconnect_node(from, from_port, to, to_port)


func connect_node(from: String, from_port: int, to: String, to_port: int) -> int:
	var from_node : GDGraphNode = get_node(from)
	var to_node : GDGraphNode = get_node(to)
	
	var from_type : int = from_node.get_connection_output_type(from_port)
	var to_type : int = to_node.get_connection_input_type(to_port)
	
	pt.connect_node(from, from_type, from_port, to, to_type, to_port)
	
	return .connect_node(from, from_port, to, to_port)


func can_drop_data(_position: Vector2, data) -> bool:
	return data is Dictionary and data.get("value_type", "") == "GDGraphNodeScene" 


func drop_data(position: Vector2, data : Dictionary) -> void:
	var gn : GraphNode = data.payload.instance()
	
	if gn is GDStartGN:
		for child in get_children():
			if child is GDStartGN:
				printerr("GraphEdit already has a StartNode")
				return
		
		gn.set_branch_index(1)
	
	emit_signal("graph_node_added", gn)
	
	add_child(gn)
	
	gn.owner = self
	gn.offset = (scroll_offset + position) / zoom


func save() -> void:
#	var packer := PackedScene.new()
#	popup_menu.owner = self
	
	s_connection_list = get_connection_list()
#	packer.pack(self)
#
#	ResourceSaver.save("res://test/test.tscn", packer)


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


func _chain_branch_update(from_node: GDGraphNode, to_node: GDGraphNode, slot: int) -> void:
	var flow_ports := from_node.get_ports(from_node.PortType.FLOW, from_node.Port.RIGHT)
	var flow_index := flow_ports.find(slot)
	
	if from_node.get_branch_index() == 0:
		to_node.set_branch_index(0)
	else:
		to_node.set_branch_index(from_node.get_branch_index() + flow_index)


func _on_connection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	if from == to:
		return
	
	var from_node : GDGraphNode = get_node(from)
	var to_node : GDGraphNode = get_node(to)

	var from_type := from_node.get_connection_output_type(from_slot)
	var to_type := to_node.get_connection_input_type(to_slot)
	
	if not from_node.connect_to(to_node, to_slot, from_slot) or \
	   not to_node.connect_from(from_node, from_slot, to_slot)\
	:
		return
	
	# One to many connection check
	match from_type:
		PortRect.PortType.FLOW:
			if is_node_right_connected(from, from_slot):
				disconnect_node_output(from, from_slot)
			
			if not from_node.is_connected("branch_updated", self, "_chain_branch_update"):
				from_node.connect("branch_updated", self, "_chain_branch_update", [from_node, to_node, from_slot])
			
			_chain_branch_update(from_node, to_node, from_slot)
	
	connect_node(from, from_slot, to, to_slot)
	


func _on_disconnection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	var from_node : GDGraphNode = get_node(from)
	var to_node : GDGraphNode = get_node(to)
	
	var from_type := from_node.get_connection_output_type(from_slot)
	var to_type := to_node.get_connection_input_type(to_slot)
	
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
