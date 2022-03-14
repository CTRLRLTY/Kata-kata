tool

extends WindowDialog

var character_data : CharacterData
var selected_expression : Control 

onready var _expression_container := find_node("CharacterExpressionContainer")
onready var _state_tree := find_node("CharacterStateTree")
onready var _file_dialog := find_node("FileDialog")


func add_expression(expression_data : CharacterExpressionData) -> void:
	var item : Control = load(GDutil.resolve("CharacterExpressionItem.tscn")).instance()
	var name_edit : LineEdit = item.get_name_edit()
	
	item.expression_data = expression_data
	item.set_expression_name(_valid_expression_name(expression_data, expression_data.expression_name))
	
	item.connect("focus_entered", self, "_on_expression_item_focus_entered", [item])
	item.connect("profile_pressed", _file_dialog, "popup_centered")
	name_edit.connect("focus_exited", self, "_on_expression_name_edit_focus_exited", [item])
	
	_expression_container.add_child(item)
	
	item.grab_focus()


func _valid_expression_name(expression: CharacterExpressionData, expression_name: String, incremental := 0, seperator := "_") -> String:	
	var suffix := seperator + String(incremental)
	
	var fullname := expression_name
	
	if incremental > 0:
		fullname  = expression_name + suffix
	
	for child in _expression_container.get_children():
		var e : CharacterExpressionData = child.expression_data
		
		if expression == e:
			continue
		
		var en : String = e.expression_name
		
		if en == fullname:
			return _valid_expression_name(expression, expression_name, incremental + 1, seperator)
	
	return fullname


func _on_about_to_show() -> void:
	assert(character_data, 
			"character_data has to be supplied before shown")
	
	for character_expression in character_data.character_expressions:
		add_expression(character_expression)


func _on_popup_hide() -> void:
	for child in _expression_container.get_children():
		child.queue_free()


func _on_expression_name_edit_focus_exited(item: Control) -> void:
	var edata : CharacterExpressionData = item.expression_data
	
	item.set_expression_name(_valid_expression_name(edata, edata.expression_name))


func _on_CharacterStateTree_state_changed() -> void:
	character_data.character_states = _state_tree.get_state_list()


func _on_AddExpressionBtn_pressed() -> void:
	var character_expression := CharacterExpressionData.new()
	add_expression(character_expression)
	character_data.character_expressions.append(character_expression)


func _on_DeleteExpressionBtn_pressed() -> void:
	if not selected_expression:
		if not _expression_container.get_child_count():
			return
			
		selected_expression = _expression_container.get_child(
				_expression_container.get_child_count()-1)
	
	character_data.character_expressions.erase(
				selected_expression.expression_data)
	
	selected_expression.queue_free()
	selected_expression = null


func _on_expression_item_focus_entered(character_expression : Control) -> void:
	selected_expression = character_expression


func _on_FileDialog_file_selected(path: String) -> void:
	var texture_resource : Texture = load(path)
	
	if selected_expression:
		selected_expression.set_texture(texture_resource) 
		selected_expression.expression_data.expression_texture = texture_resource
