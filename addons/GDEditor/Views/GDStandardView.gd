tool

extends GDDialogueView

class_name GDStandardView

signal character_file_deleted(file)
signal character_deleted(character_data)
signal character_left(character_data)
signal character_renamed(character_data)

# s_joined_claims Dictionary:
#	-> CharacterData: [GDCharacterJoinGN, ...]
export var s_joined_claims : Dictionary


onready var _character_left := find_node("CharacterLeft")
onready var _character_right := find_node("CharacterRight")
onready var _choice_container := find_node("ChoiceContainer")
onready var _text_box := find_node("TextBox")

# _joined Dictionary:
#	-> CharacterData: GDCharacterJoinGN
onready var _joined := {}


func _ready() -> void:
	var file_system := GDUtil.get_file_system_dock()
	
	if file_system:
		file_system.connect("file_removed", self, "_on_file_removed")


func _dialogue_components() -> Array:
	return [
		load(GDUtil.resolve("GDStartGN.tscn")),
		load(GDUtil.resolve("GDEndGN.tscn")),
		{
			"scene": load(GDUtil.resolve("GDMessageGN.tscn")),
			"readers": [GDMessageReader.new()]
		},
		{
			"scene": load(GDUtil.resolve("GDChoiceGN.tscn")),
			"readers": [GDChoiceReader.new()]
		},
		load(GDUtil.resolve("GDEmitterGN.tscn")),
		{
			"scene": load(GDUtil.resolve("GDCharacterJoinGN.tscn")),
			"readers": [GDCharacterJoinReader.new()]
		},
		{
			"scene": load(GDUtil.resolve("GDCharacterLeftGN.tscn")),
			"readers": [GDCharacterLeftReader.new()]
		}
	]


func _tool_buttons() -> Array:
	return [load(GDUtil.resolve("ToolCharacterOpen.tscn"))]


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
	
	if dir.dir_exists(GDUtil.get_characters_dir()):
		dir.open(GDUtil.get_characters_dir())
		dir.list_dir_begin(true, true)
		var file_name := dir.get_next()
		
		while not file_name.empty():
			var character_data : CharacterData = load(GDUtil.get_characters_dir() + file_name)
			
			if character_data:
				ret.append(character_data)
			
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	return ret


func get_joined_characters() -> Array:
	return s_joined_claims.keys()


func set_text_box(text: String) -> void:
	_text_box.text = text


func show_character(character: CharacterData, expression: CharacterExpressionData) -> void:
	var gn : GDCharacterJoinGN
	
	if _joined.has(character):
		gn = _joined[character]
	
	if not gn:
		return
	
	var position : String = gn.get_character_position_string()
	var offset : int = gn.s_character_offset
	var texture : Texture
	
	if expression:
		texture = expression.expression_texture
	
	get("_character_%s" % [position]).set_character(offset, texture, character)


# Checks the runtime join
func has_character_join(character_data: CharacterData) -> bool:
	return _joined.has(character_data)


# Runtime join
func character_rjoin(gn: GDCharacterJoinGN) -> void:
	var character_data := gn.get_character_data()
	
	if character_data:
		_joined[character_data] = gn


# Runtime left
func character_rleft(character_data: CharacterData) -> void:
	if not _joined.has(character_data):
		return
	
	var gn : GDCharacterJoinGN = _joined[character_data]
	var position := gn.get_character_position_string()
	var offset := gn.s_character_offset
	
	var character_rect = get("_character_%s" % [position])
	var index : int = character_rect.find_character(character_data)
	
	if index != -1:
		character_rect.set_character(index, null, null)
	
	_joined.erase(character_data)


func character_join(holder: GDCharacterJoinGN) -> void:
	var character_data := holder.get_character_data()
	
	var claims : Array =  s_joined_claims.get(character_data, [])
	
	if claims.has(holder):
		return
	
	claims.append(holder)
	
	s_joined_claims[character_data] = claims


func character_left(character_data: CharacterData, holder: GDGraphNode) -> void:
	if s_joined_claims.has(character_data):
		var claims : Array = s_joined_claims[character_data]
		
		claims.erase(holder)
		
		if claims.empty():
			emit_signal("character_left", character_data)


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
	if fname.get_base_dir() + "/" == GDUtil.get_characters_dir():
		emit_signal("character_file_deleted", fname)


func _on_ChoiceBtn_pressed(choice_button: Button) -> void:
	select_choice(choice_button.get_index())
