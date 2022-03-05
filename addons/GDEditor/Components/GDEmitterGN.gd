tool

extends GDGraphNode

class_name GDEmitterGN

export var s_event_name : String

onready var _event_edit := find_node("EventEdit")


func _ready() -> void:
	_event_edit.text = s_event_name


func get_component_name() -> String:
	return "Emitter"


func get_save_data() -> String:
	return s_event_name


func get_readers() -> Array:
	return [GDEmitterReader.new()]


func _on_SignalEdit_text_changed(new_text: String) -> void:
	s_event_name = new_text
