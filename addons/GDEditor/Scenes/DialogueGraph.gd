tool

extends GraphEdit

class_name DialogueGraph

# emitted before added to child
signal graph_node_add(graph_node)
# emitted after added to child and is ready
signal graph_node_added(graph_node)
signal graph_node_removed(node_name)

export var s_connection_list : Array

# GDPortMap
export var pt : Resource 

var _selected_nodes := []
var _copy_buffer := []

onready var popup_menu: PopupMenu = $DGPopupMenu


func _ready() -> void:
	popup_menu.connect("id_pressed", self, "_on_popup_menu_pressed")

	connect("connection_request", self, "_on_connection_request")
	connect("disconnection_request", self, "_on_disconnection_request")
	connect("node_selected", self, "_on_node_selected")
	connect("node_unselected", self, "_on_node_unselected")
	connect("popup_request", self, "_on_popup_request")
	
	add_valid_connection_type(PortRect.PortType.UNIVERSAL, PortRect.PortType.UNIVERSAL)
	add_valid_connection_type(PortRect.PortType.UNIVERSAL, PortRect.PortType.ACTION)
	add_valid_connection_type(PortRect.PortType.UNIVERSAL, PortRect.PortType.FLOW)
	
	add_valid_connection_type(PortRect.PortType.ACTION, PortRect.PortType.ACTION)
	add_valid_connection_type(PortRect.PortType.ACTION, PortRect.PortType.UNIVERSAL)
	
	add_valid_connection_type(PortRect.PortType.FLOW, PortRect.PortType.FLOW)
	add_valid_connection_type(PortRect.PortType.FLOW, PortRect.PortType.UNIVERSAL)
	
	add_valid_left_disconnect_type(PortRect.PortType.FLOW)
	add_valid_left_disconnect_type(PortRect.PortType.UNIVERSAL)
	
	if not pt:
		pt = GDPortMap.new()
	
	port_map().connect("connected", self, "_on_node_connected")
	port_map().connect("disconnected", self, "_on_node_disconnected")
	
	for conn in s_connection_list:
		connect_node(conn.from, conn.from_port, conn.to, conn.to_port)
	
	port_map().connect("depth_set", self, "_on_node_depth_set")


func can_drop_data(_position: Vector2, data) -> bool:
	return data is Dictionary and data.get("value_type", "") == "GDGraphNodeScene" 


func drop_data(position: Vector2, data : Dictionary) -> void:
	var gn : GraphNode = data.payload.instance()
	
	if gn is GDStartGN:
		for child in get_children():
			if child is GDStartGN:
				printerr("GraphEdit already has a StartNode")
				return
	
	emit_signal("graph_node_add", gn)
	
	add_child(gn)
	
	var node_name := gn.name
	
	if gn is GDEndGN:
		port_map().set_node_depth(node_name, 1) 
	
	gn.owner = owner
	gn.offset = (scroll_offset + position) / zoom
	
	yield(get_tree(), "idle_frame")
	emit_signal("graph_node_added", gn)


func port_map() -> GDPortMap:
	return pt as GDPortMap


func save() -> void:
	popup_menu.owner = owner
	s_connection_list = get_connection_list()


func _chain_depth_update(old_depth: int, new_depth: int, prev_node : GDGraphNode) -> void:
	var node_name := prev_node.name
	var node_depth := port_map().get_node_depth(node_name)
	port_map().set_node_depth(prev_node.name, node_depth + new_depth - old_depth)


func _on_connection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	if from == to:
		return
	
	var from_node : GDGraphNode = get_node(from)
	var to_node : GDGraphNode = get_node(to)

	var from_type := from_node.get_connection_output_type(from_slot)
	var to_type := to_node.get_connection_input_type(to_slot)
	
	if not from_node.connection_to(to_node, to_slot, from_slot) or \
	   not to_node.connection_from(from_node, from_slot, to_slot)\
	:
		return
	
	# One to many connection check
	match from_type:
		PortRect.PortType.FLOW:
			if port_map().right_connected(from, from_slot):
				port_map().right_disconnect(from, from_slot)
			
			if not to_node.is_connected("depth_updated", self, "_chain_depth_update"):
				to_node.connect("depth_updated", self, "_chain_depth_update", [from_node])
			
			if not port_map().has_connection(from, to):
				port_map().set_node_depth(from, to_node.get_depth() + from_node.get_depth())
		
		
	port_map().connect_node(from, from_type, from_slot, to, to_type, to_slot)


func _on_disconnection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	var from_node : GDGraphNode = get_node(from)
	var to_node : GDGraphNode = get_node(to)
	
	var from_type := from_node.get_connection_output_type(from_slot)
	var to_type := to_node.get_connection_input_type(to_slot)
	
	if not from_node.disconnection_to(to_node, to_slot, from_slot) or \
	   not to_node.disconnection_from(from_node, from_slot, to_slot)\
	:
		return
	
	port_map().disconnect_node(from, from_slot, to, to_slot)


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
				port_map().clear_connection(node.name)
				emit_signal("graph_node_removed", node.name)
				
				node.queue_free()
			
			_selected_nodes.clear()


func _on_node_selected(node: Node) -> void:
	_selected_nodes.append(node)
	
	
func _on_node_unselected(node: Node) -> void:
	_selected_nodes.erase(node)


func _on_node_connected(from: String, from_slot: int, to: String, to_slot: int) -> void:
	connect_node(from, from_slot, to, to_slot)


func _on_node_disconnected(from: String, from_slot: int, to: String, to_slot: int) -> void:
	if not port_map().has_connection(from, to):
		var to_node : GDGraphNode = get_node(to)
		var from_depth := port_map().get_node_depth(from)
		var to_depth := port_map().get_node_depth(to)
		var depth := from_depth - to_depth
		
		port_map().set_node_depth(from , depth)
	
		if to_node.is_connected("depth_updated", self, "_chain_depth_update"):
			to_node.disconnect("depth_updated", self, "_chain_depth_update")
	
	disconnect_node(from, from_slot, to, to_slot)


func _on_node_depth_set(node_name: String, depth: int) -> void:
	if has_node(node_name):
		var gn : GDGraphNode = get_node(node_name)
		gn.set_depth(depth)
