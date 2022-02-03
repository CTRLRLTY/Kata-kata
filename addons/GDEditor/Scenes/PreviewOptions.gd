tool

extends OptionButton


func _enter_tree() -> void:
	clear()
	
	var d := Directory.new()
	d.open(GDUtil.get_view_dir())
	d.list_dir_begin(true, true)
	
	var file_name := d.get_next()
	
	while not file_name.empty():
		var ext := file_name.get_extension()
		
		if ext == "tscn":
			var basename := file_name.get_basename()
			var packed : PackedScene = load(GDUtil.resolve(file_name))
			var scene = packed.instance()
			
			if scene is GDDialogueView:
				add_item(basename)
				set_item_metadata(get_item_count() - 1, packed)
		
		file_name = d.get_next()

	d.list_dir_end()
