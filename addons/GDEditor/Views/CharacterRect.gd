tool

extends MarginContainer



onready var _characters := []


func _ready() -> void:
	_characters.resize(get_child_count())


func set_character(idx: int, texture: Texture, character_data: CharacterData = null) -> void:
	_characters[idx] = character_data
	get_child(idx).set_texture(texture)


func find_character(character_data: CharacterData) -> int:
	return _characters.find(character_data)


func clear_textures() -> void:
	for child in get_children():
		child.set_texture(null)
	
	_characters.clear()
	_characters.resize(get_child_count())
