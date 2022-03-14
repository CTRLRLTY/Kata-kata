tool

extends ConfirmationDialog


onready var _search_box : LineEdit = find_node("SearchBox")
onready var _search_options : Tree = find_node("SearchOptions")

var _search_path : String
var _base_type : String


func _ready() -> void:
	get_ok().text = "Open"
	get_ok().disabled = true
	
	_search_options.select_mode = Tree.SELECT_ROW
	_search_options.hide_root = true
	_search_options.hide_folding = true


func popup_dialog(base_type: String, search_path: String) -> void:
	_base_type = base_type
	_search_path = search_path
	
	popup_centered_ratio(0.4)
	_search_box.grab_focus()


func get_selected() -> String:
	var ti := _search_options.get_selected()
	
	if ti:
		return ti.get_text(0)
	
	return ""


func _update_search() -> void:
	_search_options.clear()
	var root := _search_options.create_item()
	
	var fs := GDUtil.get_file_system()
	
	if not fs:
		GDUtil.print([self, " can't call get_file_system() when not running in Editor"], GDUtil.PR_ERR, 0)
		return
	
	var efsd := fs.get_filesystem_path(_search_path)
	
	var file_count := efsd.get_file_count()
	
	for i in file_count:
		var file := efsd.get_file_path(i)
		
		# 6 == 'res://'.lenght()
		file = file.substr(6, file.length())
		
		if efsd.get_file_type(i) == _base_type and _search_box.text.is_subsequence_ofi(file):
			var ti := _search_options.create_item(root)
			var icon := GDUtil.get_icon(_base_type)
			
			ti.set_text(0, file)
			ti.set_icon(0, icon)
	
	
	if(root.get_children()):
		var ti := root.get_children()
		
		ti.select(0)
	
	
	get_ok().disabled = root.get_children() == null


func _on_about_to_show() -> void:
	_update_search()


func _on_SearchBox_text_changed(new_text: String) -> void:
	_update_search()


func _on_SearchBox_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		match event.scancode:
			KEY_UP, KEY_DOWN, KEY_PAGEUP, KEY_PAGEDOWN:
				_search_options._gui_input(event)
				_search_box.accept_event()
			KEY_ENTER:
				hide()
				emit_signal("confirmed")


func _on_SearchOptions_item_activated() -> void:
	hide()
	emit_signal("confirmed")
