tool

extends PanelContainer

signal drag_start
signal drag_end

enum {
	NONE = -2
	GUIDE_TOP,
	GUIDE_CENTER, 
	GUIDE_BOTTOM,
}

var drag_btn : ToolButton
var index_label : Label
var value_edit : LineEdit

var _draw_guides : bool
var _mouse_on_node := false
var _active_guide := NONE


func _enter_tree() -> void:
#	set_process(false)
	drag_btn = $"HBoxContainer/DragBtn"
	index_label = $"HBoxContainer/IndexLabel"
	value_edit = $"HBoxContainer/ValueEdit"
	
	_draw_guides = false


func _draw() -> void:
	if _draw_guides and get_global_rect().has_point(get_global_mouse_position()):
		var left := GDutil.control_border_left(self)
		var top := GDutil.control_border_top(self)
		var right := GDutil.control_border_right(self)
		var bottom := GDutil.control_border_bottom(self)
		
		var top_distance := GDutil.line_centroidv(top).distance_squared_to(get_local_mouse_position())
		var bottom_distance := GDutil.line_centroidv(bottom).distance_squared_to(get_local_mouse_position())
		var center_distance := GDutil.control_centroid(self).distance_squared_to(get_local_mouse_position())

		
		if bottom_distance < top_distance and bottom_distance < center_distance:		
			draw_line(bottom[0], bottom[1], Color.aqua, 2.0)
			
			_active_guide = GUIDE_BOTTOM
			
		elif top_distance < center_distance and top_distance < bottom_distance:
			draw_line(top[0], top[1], Color.aqua, 2.0)
			
			_active_guide = GUIDE_TOP
			
		else:
			draw_line(left[0], left[1], Color.aqua, 2.0)
			draw_line(top[0], top[1], Color.aqua, 2.0)
			draw_line(right[0], right[1], Color.aqua, 2.0)
			draw_line(bottom[0], bottom[1], Color.aqua, 2.0)
			
			_active_guide = GUIDE_CENTER
	else:
		_active_guide = NONE
			
			
func _gui_input(event: InputEvent) -> void:
	if _draw_guides:
		if event is InputEventMouseMotion:
			update()
			
			
func _process(delta: float) -> void:
	# It's a workaround, because calling we can't call set_process in enter_tree.
	if not _draw_guides:
		set_process(false)
		return
	
	if not Input.is_mouse_button_pressed(BUTTON_LEFT):
		emit_signal("drag_end")
		set_process(false)


func get_active_guide() -> int:
	return _active_guide


func set_draw_guides(enable : bool) -> void:
	_draw_guides = enable
	
	update()
	
		
func _on_mouse_entered() -> void:
	if _draw_guides:
		update()
	

func _on_mouse_exited() -> void:
	if _draw_guides:
		update()


func _on_DragBtn_pressed() -> void:
	emit_signal("drag_start")
	set_process(true)
