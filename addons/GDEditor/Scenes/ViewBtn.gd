tool

extends Button

signal view_changed(dialogue_view)


onready var _quick_open := $QuickOpen


func _ready() -> void:
	pass


func get_quick_open() -> ConfirmationDialog:
	return _quick_open as ConfirmationDialog


func _on_pressed() -> void:
	_quick_open.popup_dialog("PackedScene", GDUtil.get_view_dir())


func _on_quick_open_confirmed() -> void:
	var view_path : String = _quick_open.get_selected()
	
	if not view_path.empty():
		var dv = load("res://" + view_path).instance()
	
		if dv is GDDialogueView:
			text = dv.get_view_name()
			
			emit_signal("view_changed", dv)
