tool

extends GDGraphNode

class_name GDPipeGN

export var s_type : int

enum PipeType {
	CONDITION,
	WAIT_FOR,
	WAIT_TILL,
}


func _ready() -> void:
	set_type(s_type)


func get_component_name() -> String:
	return "Pipe"


func set_type(type_id : int) -> void:
	if get_dialogue_graph():
		get_dialogue_graph().clear_node_connections(self)
		
	clear_all_slots()
	_clear_attachment()
	
	# Wait till attachments are cleared
	while not get_child_count() == 1:
		yield(get_tree(), "idle_frame")
		
	rect_size = Vector2.ZERO # Re-adjust size

	match type_id:
		PipeType.CONDITION:
			_add_attachment("ExpressionEdit")
			_add_attachment("TrueSection")
			_add_attachment("FalseSection")
		PipeType.WAIT_FOR:
			_add_attachment("WaitSection")
		PipeType.WAIT_TILL:
			_add_attachment("SignalEditSection")
	
	s_type = type_id


func get_type() -> int:
	return s_type


func get_output_ports_type() -> int:
	# It is assumed that the rest of the output ports are of same types
	return get_connection_output_type(0)


func deny_from(graph_node: GDGraphNode, to_slot: int, from_slot: int) -> bool:
	var from_type := get_connection_input_type(from_slot)
	
	if from_type == PortType.UNIVERSAL:
		var to_type := graph_node.get_connection_output_type(to_slot)
		if not get_output_ports_type() == to_type:
			if is_connection_connected_input(from_slot):
				return true
			
			change_all_outport(to_type)
	
	return false


func change_all_outport(to_type: int) -> void:
	if get_dialogue_graph():
		get_dialogue_graph().clear_node_connections(self)
	
	for port_rect in get_port_rects_right():
		port_rect.set_port_type(to_type)


func _add_attachment(attachment_name : String) -> void:
	var attachment_path := GDUtil.get_attachment_dir() + attachment_name + ".tscn"
	var attachment : PackedScene = load(attachment_path)

	assert(File.new().file_exists(attachment_path), "Attachment: %s does not exist" % attachment_path)

	add_child(attachment.instance())


func _clear_attachment() -> void:
	var attachments := get_children()
	attachments.pop_front() # Exclude Header

	for attachment in attachments:
		attachment.queue_free()


func _on_OptionTypeBtn_item_selected(index: int) -> void:
	set_type(index)
