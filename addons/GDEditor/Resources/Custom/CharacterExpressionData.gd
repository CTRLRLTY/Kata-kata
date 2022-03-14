extends Resource

class_name CharacterExpressionData

export(Texture) var expression_texture
export(String) var expression_name


func _init() -> void:
	expression_texture = load(GDutil.resolve("icon.png"))
	expression_name = "owo"
