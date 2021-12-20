tool

extends GraphNode

export(String, MULTILINE) var message_text 

var message_edit : TextEdit

func _enter_tree() -> void:
	message_edit = find_node("MessageEdit")
	
	message_edit.text = message_text


func _on_MessageEdit_text_changed() -> void:
	message_text = message_edit.text
