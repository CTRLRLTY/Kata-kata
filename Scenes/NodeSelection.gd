tool

extends ItemList

const Items = [
	{
		"name": "CharacterJoin",
		"icon": null
	},
	{
		"name": "CharacterLeft",
		"icon": null
	},
	{
		"name": "ShowMessage",
		"icon": null
	},
	{
		"name": "Choices",
		"icon": null
	},
	{
		"name": "Pipe",
		"icon": null
	},
	{
		"name": "Setter",
		"icon": null
	},
	{
		"name": "Getter",
		"icon": null
	},
	{
		"name": "Setter",
		"icon": null
	},
	{
		"name": "Emitter",
		"icon": null
	}
]

func _enter_tree() -> void:
	for item in Items:
		add_item(item.name, item.icon)
		
func _exit_tree() -> void:
	clear()

func get_drag_data(position: Vector2):
	var preview_control := PanelContainer.new()
	var selected_item_id := get_item_at_position(position)
	set_drag_preview(preview_control)
	return "hello"
