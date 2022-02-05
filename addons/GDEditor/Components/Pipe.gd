tool

extends GDGraphNode

class_name GNPipe

signal type_changed(from, to)

export var s_type : int

enum PipeType {
	CONDITION,
	WAIT_FOR,
	WAIT_TILL,
}


func _ready() -> void:
	set_type(s_type)


func set_type(type_id : int) -> void:
	emit_signal("type_changed", s_type, type_id)
	
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


func get_component_name() -> String:
	return "Pipe"


func get_type() -> int:
	return s_type


func get_output_ports_type() -> int:
	# It is assumed that the rest of the output ports are of same types
	return get_slot_type_right(slot2port(0, GDGraphNode.Port.RIGHT))


func deny_from(graph_node: GDGraphNode, from_port: int, from_type: int, to_port: int, to_type: int) -> bool:
	if to_type == PortType.UNIVERSAL:
		if is_slot_connected_left(to_port):
			if not get_output_ports_type() == from_type:
				return true
		
		change_all_outport(from_type)
	
	return false


func change_all_outport(to_type: int) -> void:
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
