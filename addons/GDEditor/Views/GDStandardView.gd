tool

extends GDDialogueView

class_name GDStandardView

onready var choice_container := find_node("ChoiceContainer")
onready var character_left_rect := find_node("CharacterLeftRect")
onready var character_right_rect := find_node("CharacterRightRect")
onready var text_box := find_node("TextBox")


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				next()


func get_readers() -> Array:
	return [GDMessageReader.new()]


func get_components() -> Array:
	# Returns an Array of PackedScenes
	return [load(GDUtil.resolve("Start.tscn")),
			load(GDUtil.resolve("End.tscn")),
			load(GDUtil.resolve("Message.tscn")),
			load(GDUtil.resolve("CharacterJoin.tscn")),
			load(GDUtil.resolve("Pipe.tscn")),
			load(GDUtil.resolve("Choice.tscn")),
			load(GDUtil.resolve("CharacterJoin.tscn"))]


func get_tools() -> Array:
	return [load(GDUtil.resolve("ToolCharacterOpen.tscn"))]


func set_text_box(text: String) -> void:
	text_box.text = text


func set_character_left_rect(texture: Texture) -> void:
	character_left_rect.texture = texture


func set_character_right_rect(texture: Texture) -> void: 
	character_right_rect.texture = texture


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
	set_character_left_rect(null)
	set_character_right_rect(null)
	set_text_box("")


