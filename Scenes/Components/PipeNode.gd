extends GraphNode

enum PipeType {
	CONDITION,
	EXPRESSION,
	WAIT_FOR,
	WAIT_TILL,
}

var option_type : OptionButton

func _enter_tree() -> void:
	option_type = find_node("OptionTypeBtn")
	set_type(get_type())

	
func set_type(type_id : int) -> void:
	
	_clear_attachment()
	yield(get_tree(), "idle_frame")
	rect_size = Vector2.ZERO # Re-adjust size
	
	match type_id:
		PipeType.CONDITION:
			_add_attachment("ExpressionEdit")
			_add_attachment("TrueSection")
			_add_attachment("FalseSection")
		PipeType.EXPRESSION:
			_add_attachment("ExpressionSection")
		PipeType.WAIT_FOR:
			_add_attachment("WaitSection")
		PipeType.WAIT_TILL:
			_add_attachment("SignalEditSection")


func get_type() -> int:
	return option_type.get_selected_id()


func _add_attachment(attachment_name : String) -> void:
	var attachment_dir := "res://Scenes/Components/Attachments/"
	var attachment_path := attachment_dir + attachment_name + ".tscn"
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
