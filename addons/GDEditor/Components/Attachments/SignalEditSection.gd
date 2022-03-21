tool

extends HBoxContainer

signal wait_finished


onready var _signal_label := $SignalEdit


func start() -> void:
	var signal_name = _signal_label.text
	
	if not Kata2.has_signal(signal_name):
		Kata2.add_user_signal(signal_name)
		
	yield(Kata2, signal_name)
	
	emit_signal("wait_finished")
