tool

extends GDDialogueView

class_name GDStandardView

signal character_file_deleted(file)
signal character_deleted(character_data)
signal character_left(character_data)
signal character_renamed(character_data)


export var s_joined_characters : Dictionary
export var s_joined_claims : Dictionary


onready var _character_left := find_node("CharacterLeft")
onready var _character_right := find_node("CharacterRight")
onready var _choice_container := find_node("ChoiceContainer")
onready var _text_box := find_node("TextBox")
onready var _joined := []


func _ready() -> void:
	var file_system := GDUtil.get_file_system_dock()
	
	if file_system:
		file_system.connect("file_removed", self, "_on_file_removed")


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				next()


func _get_components() -> Array:
	return [
		load(GDUtil.resolve("GDStartGN.tscn")),
		load(GDUtil.resolve("GDEndGN.tscn")),
		{
			"scene": load(GDUtil.resolve("GDMessageGN.tscn")),
			"readers": [GDMessageReader.new()]
		},
		{
			"scene": load(GDUtil.resolve("GDPipeGN.tscn")),
			"readers": [GDPipeReader.new()]
		},
		load(GDUtil.resolve("GDChoiceGN.tscn")),
		{
			"scene": load(GDUtil.resolve("GDCharacterJoinGN.tscn")),
			"readers": [GDCharacterJoinReader.new()]
		},
		load(GDUtil.resolve("GDCharacterLeftGN.tscn"))
	]


func _get_tools() -> Array:
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
	return s_joined_characters.keys()


func set_text_box(text: String) -> void:
	_text_box.text = text


func show_character(character: CharacterData, expression: CharacterExpressionData) -> void:
	var jdata : Dictionary = s_joined_characters.get(character)
	
	if not jdata:
		return

	var position : String = GDCharacterJoinGN.CharacterPosition.keys()[jdata.position].to_lower()
	
	get("_character_%s" % [position]).set_texture(expression.expression_texture, jdata.position)


# Checks the runtime join
func has_character_join(character_data: CharacterData) -> bool:
	return _joined.has(character_data)


# Runtime join
func character_rjoin(character_data: CharacterData) -> void:
	if _joined.has(character_data):
		return
	
	_joined.append(character_data)


# Runtime left
func character_rleft(character_data: CharacterData) -> void:
	_joined.erase(character_data)


func character_join(character_data: CharacterData, holder: GDCharacterJoinGN) -> void:
	if not character_data or not is_instance_valid(holder):
		return
	
	var claims : Array =  s_joined_claims.get(character_data, [])
	
	if claims.has(holder):
		return
	
	claims.append(holder)
	
	s_joined_claims[character_data] = claims
	s_joined_characters[character_data] = {
		"position": holder.get_character_position(),
		"offset": holder.s_character_offset
	}


func character_left(character_data: CharacterData, holder: GDGraphNode) -> void:
	if s_joined_claims.has(character_data):
		var claims : Array = s_joined_claims[character_data]
		
		claims.erase(holder)
		
		if claims.empty():
			var position : String = holder.CharacterPosition\
					.keys()[holder.get_character_position()].to_lower()
			
			s_joined_characters.erase(character_data)
			emit_signal("character_left", character_data)


func show_choices(questions: PoolStringArray) -> void:
	for question in questions:
		var button := Button.new()
		button.text = question
		
		_choice_container.add_child(button)


func hide_choices() -> void:
	_choice_container.hide()


func clear_choices() -> void:
	for child in _choice_container.get_children():
		queue_free()


func reset() -> void:
	clear_choices()
	_character_left.clear_textures()
	_character_right.clear_textures()
	_joined.clear()
	set_text_box("")


func _on_file_removed(fname: String) -> void:
	if fname.get_base_dir() + "/" == GDUtil.get_characters_dir():
		emit_signal("character_file_deleted", fname)
