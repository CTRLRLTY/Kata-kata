tool

extends GDDialogueView

class_name GDStandardView

signal character_file_deleted(file)
signal character_deleted(character_data)
signal character_renamed(character_data)

onready var _character_left := find_node("CharacterLeft")
onready var _character_right := find_node("CharacterRight")
onready var _choice_container := find_node("ChoiceContainer")
onready var _text_box := find_node("TextBox")

# _joined Dictionary:
#	-> CharacterData: 
#		-> "position": int
#		-> "offset": int
onready var _joined := {}


func _ready() -> void:
	var file_system := GDutil.get_file_system_dock()
	
	if file_system:
		file_system.connect("file_removed", self, "_on_file_removed")


func _dialogue_components() -> Array:
	return [
		load(GDutil.resolve("GDStartGN.tscn")),
		load(GDutil.resolve("GDEndGN.tscn")),
		{
			"scene": load(GDutil.resolve("GDMessageGN.tscn")),
			"readers": [GDMessageReader.new()]
		},
		{
			"scene": load(GDutil.resolve("GDChoiceGN.tscn")),
			"readers": [GDChoiceReader.new()]
		},
		load(GDutil.resolve("GDEmitterGN.tscn")),
		{
			"scene": load(GDutil.resolve("GDCharacterJoinGN.tscn")),
			"readers": [GDCharacterJoinReader.new()]
		},
		{
			"scene": load(GDutil.resolve("GDCharacterLeftGN.tscn")),
			"readers": [GDCharacterLeftReader.new()]
		}
	]


func _tool_buttons() -> Array:
	return [load(GDutil.resolve("ToolCharacterOpen.tscn"))]


func get_view_name() -> String:
	return "Standard View"


func get_class() -> String:
	return "GDStandardView"


func get_character_names() -> PoolStringArray:
	var dir := Directory.new()
	
	var ret := PoolStringArray([])
	
	for character_data in get_character_datas():
		ret.append(character_data.character_name)
	
	return ret


func get_character_datas() -> Array:
	var dir := Directory.new()
	var ret := []
	
	if dir.dir_exists(GDutil.get_characters_dir()):
		dir.open(GDutil.get_characters_dir())
		dir.list_dir_begin(true, true)
		var file_name := dir.get_next()
		
		while not file_name.empty():
			var character_data : CharacterData = load(GDutil.get_characters_dir() + file_name)
			
			if character_data:
				ret.append(character_data)
			
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	return ret


func set_text_box(text: String) -> void:
	_text_box.text = text


func show_character(character: CharacterData, expression: CharacterExpressionData) -> void:
	var data : Dictionary
	
	if _joined.has(character):
		data = _joined[character]
	
	if not data:
		return
	
	var texture : Texture
	
	if expression:
		texture = expression.expression_texture
	
	get("_character_%s" % [data.position]).set_character(data.offset, texture, character)


# Checks the runtime join
func has_character_join(character_data: CharacterData) -> bool:
	return _joined.has(character_data)


# Runtime join
func character_rjoin(character_data: CharacterData, pos: String, offset: int) -> void:
	if character_data:
		_joined[character_data] = {
			"position": pos,
			"offset": offset
		}


# Runtime left
func character_rleft(character_data: CharacterData) -> void:
	if not _joined.has(character_data):
		return
	
	var data : Dictionary = _joined[character_data]
	var position : String = data.position
	var offset : int = data.offset
	
	var character_rect = get("_character_%s" % [position])
	var index : int = character_rect.find_character(character_data)
	
	if index != -1:
		character_rect.set_character(index, null, null)
	
	_joined.erase(character_data)


func show_choices(questions: PoolStringArray) -> void:
	for question in questions:
		var button := Button.new()
		button.text = question
		
		_choice_container.add_child(button)
		button.connect("pressed", self, "_on_ChoiceBtn_pressed", [button])
	
	_choice_container.show()


func hide_choices() -> void:
	_choice_container.hide()


func clear_choices() -> void:
	for child in _choice_container.get_children():
		child.queue_free()


func reset() -> void:
	clear_choices()
	_character_left.clear_textures()
	_character_right.clear_textures()
	_joined.clear()
	set_text_box("")


func _on_file_removed(fname: String) -> void:
	if fname.get_base_dir() + "/" == GDutil.get_characters_dir():
		emit_signal("character_file_deleted", fname)


func _on_ChoiceBtn_pressed(choice_button: Button) -> void:
	select_choice(choice_button.get_index())
