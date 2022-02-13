tool

extends GDGraphNode

class_name GNMessage

export(String, MULTILINE) var s_message 

var message_edit : TextEdit


func _enter_tree() -> void:
	message_edit = find_node("MessageEdit")
	
	message_edit.text = s_message


func get_component_name() -> String:
	return "Message"


func _on_MessageEdit_text_changed() -> void:
	s_message = message_edit.text


func deny_to(graph_node: GDGraphNode, from_slot: int, to_slot: int) -> bool:
	if self is graph_node.get_script():
		if graph_node.get_connection_input_type(from_slot) == PortType.ACTION and \
			get_connection_output_type(to_slot) == PortType.ACTION:
			return true
	
	return false
