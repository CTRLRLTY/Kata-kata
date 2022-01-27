tool

extends GDGraphNode

class_name GNPipe

enum PipeType {
	CONDITION,
	WAIT_FOR,
	WAIT_TILL,
}


func _ready() -> void:
	set_type(get_type())
	
	yield(get_tree(), "idle_frame")
	
	change_all_outport(PortRect.PortType.FLOW)


func set_type(type_id : int) -> void:
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
	
	yield(get_tree(), "idle_frame")
	_setup_port_slot()
	

func get_type() -> int:
	return find_node("OptionTypeBtn").get_selected_id()


func change_all_outport(to_type: int) -> void:
	for slot in _slot_output_table:
		_slot_table[slot].port_rect_out.s_port_type = to_type


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
