tool

extends HBoxContainer

signal wait_finished


onready var _signal_label := $SignalEdit


func start() -> void:
	var signal_name = _signal_label.text
	
	if not Gaelog.has_signal(signal_name):
		Gaelog.add_user_signal(signal_name)
		
	yield(Gaelog, signal_name)
	
	emit_signal("wait_finished")
