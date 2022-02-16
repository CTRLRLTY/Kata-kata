tool

extends GDGraphNode

class_name GDEmitterGN

export(String) var signal_name


func _enter_tree() -> void:
	find_node("SignalEdit").text = signal_name


func get_component_name() -> String:
	return "Emitter"


func _on_SignalEdit_text_changed(new_text: String) -> void:
	signal_name = new_text
