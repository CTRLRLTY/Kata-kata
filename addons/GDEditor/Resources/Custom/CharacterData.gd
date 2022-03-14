extends Resource

class_name CharacterData

export(String) var character_name
export(String, MULTILINE) var character_description
export(Texture) var profile_texture

# CharacterExpressionData List
export(Array, Resource) var character_expressions

# ContextStateData List
export(Array, Resource) var character_states


func _init() -> void:
	character_name = "Scr1pti3"
	profile_texture = load(GDutil.resolve("icon.png"))
