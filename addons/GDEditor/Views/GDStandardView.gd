tool

extends GDDialogueView

class_name GDStandardView

signal character_file_deleted(file)
signal character_deleted(character_data)
signal character_left(character_data)
signal character_renamed(character_data)


var _joined_characters := []
var _joined_claims := {}

onready var choice_container := find_node("ChoiceContainer")
onready var character_left_rect := find_node("CharacterLeftRect")
onready var character_right_rect := find_node("CharacterRightRect")
onready var text_box := find_node("TextBox")


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
	return _joined_characters


func set_text_box(text: String) -> void:
	text_box.text = text


func set_character_left_texture(texture: Texture) -> void:
	character_left_rect.texture = texture


func set_character_right_texture(texture: Texture) -> void: 
	character_right_rect.texture = texture


func character_join(character_data: CharacterData, holder: GDGraphNode) -> void:
	if not character_data or not is_instance_valid(holder):
		return
	
	var claims : Array =  _joined_claims.get(character_data, [])
	
	if claims.has(holder):
		return
	
	claims.append(holder)
	
	_joined_claims[character_data] = claims
	
	if _joined_characters.has(character_data):
		return
	
	_joined_characters.append(character_data)


func character_left(character_data: CharacterData, holder: GDGraphNode) -> void:
	if _joined_claims.has(character_data):
		var claims : Array = _joined_claims[character_data]
		
		claims.erase(holder)
		
		if claims.empty():
			_joined_characters.erase(character_data)
			emit_signal("character_left", character_data)


func show_choices(questions: PoolStringArray) -> void:
	for question in questions:
		var button := Button.new()
		button.text = question
		
		choice_container.add_child(button)


func hide_choices() -> void:
	choice_container.hide()


func clear_choices() -> void:
	for child in choice_container.get_children():
		queue_free()


func clear() -> void:
	clear_choices()
	set_character_left_texture(null)
	set_character_right_texture(null)
	set_text_box("")


func _on_file_removed(fname: String) -> void:
	if fname.get_base_dir() + "/" == GDUtil.get_characters_dir():
		emit_signal("character_file_deleted", fname)
