tool

extends HBoxContainer

signal wait_finished

enum Unit {
	SECONDS,
	MILLISECONDS
}

var _float_filter := RegEx.new()

onready var _timer := $Timer
onready var _value_edit := $ValueEdit


func _ready() -> void:
	_float_filter.compile("[-]?\\d*\\.?\\d+")


func start() -> void:
	var amount : float = _value_edit.text.to_float()
	
	_timer.start(amount)


func _on_Timer_timeout() -> void:
	emit_signal("wait_finished")


func _on_ValueEdit_focus_exited() -> void:
	GDUtil.filter_edit(_float_filter, _value_edit)
