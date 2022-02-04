tool

extends HBoxContainer


func add_child(btn: Node, legible_unique_name := false) -> void:
	assert(btn is TextureButton)
	
	btn.expand = true
	btn.rect_min_size = Vector2(24, 24)
	
	.add_child(btn)
