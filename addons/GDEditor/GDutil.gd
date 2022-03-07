extends Reference

class_name GDUtil


const _state := {}
const _resolved_path_cache := {}


static func get_characters_dir() -> String:
	return get_definitions_dir() + "Characters/"


static func get_definitions_dir() -> String:
	return "res://addons/GDEditor/Definitions/"


static func get_tool_dir() -> String:
	return "res://addons/GDEditor/Tools/"


static func get_view_dir() -> String:
	return "res://addons/GDEditor/Views/"


static func get_scene_dir() -> String:
	return "res://addons/GDEditor/Scenes/"
	
	
static func get_component_dir() -> String:
	return "res://addons/GDEditor/Components/"


static func get_attachment_dir() -> String:
	return get_component_dir() + "Attachments/"


static func get_icon_dir() -> String:
	return "res://addons/GDEditor/Resources/Icons/"


static func get_gaelog_path() -> String:
	return "res://addons/GDEditor/Gaelog.tscn"


static func get_icon(icon_name : String) -> Texture:
	var ret : Texture
	
	if get_editor_plugin():
		ret = get_editor_interface().get_base_control().get_icon(icon_name, "EditorIcons")
	else:
		# All icons has to be a .png
		ret = load(resolve(icon_name + ".png")) as Texture
		
	return ret


static func get_editor_plugin() -> EditorPlugin:
	return _state.get("editor_plugin")


static func get_editor_interface() -> EditorInterface:
	if get_editor_plugin():
		return get_editor_plugin().get_editor_interface()
	
	return null


static func get_file_system_dock() -> FileSystemDock:
	var editor_plugin := get_editor_plugin()
	
	if editor_plugin:
		var editor_interface := editor_plugin.get_editor_interface()
		return editor_interface.get_file_system_dock() 
	
	return null


static func get_file_system() -> EditorFileSystem:
	if get_editor_interface():
		return get_editor_interface().get_resource_filesystem()

	return null


# Returns GDDialogueEditor class
static func get_dialogue_editor() -> Control:
	return _state.get("dialogue_editor")


static func get_state(key: String, default = null):
	return _state.get(key, default)


static func set_dialogue_editor(dialogue_editor: Control) -> void:
	_state["dialogue_editor"] = dialogue_editor


static func set_editor_plugin(editor_plugin: EditorPlugin) -> void:
	_state["editor_plugin"] = editor_plugin 


static func regex_match(s : String, rgx : RegEx) -> bool:
	var result := rgx.search(s)
	
	if not result:
		return false
	else:	
		return s == result.get_string()


static func regex_filter(s : String, rgx : RegEx) -> String:
	var result := rgx.search(s)
	
	return result.get_string()


# find by value
static func dictionary_findv(dict: Dictionary, keyvalarr: Array) -> Array:
	var erased := []
	
	for key in dict:
		for keyval in keyvalarr:
			assert(keyval is Dictionary)
			
			var tacc := 0
			var tsize : int = keyval.size()
			
			for value in keyval.values():
				if typeof(value) != typeof(dict[key]):
					break
				
				if value != dict[key]:
					break
				
				tacc += 1
			
			if tsize == tacc:
				erased.append(key)
	
	return erased

# Remove by value
static func dictionary_removev(dict: Dictionary, keyvalarr: Array) -> void:
	for key in dictionary_findv(dict, keyvalarr):
		dict.erase(key)


static func array_swap_elementidx(arr : Array, from_idx : int, to_idx : int) -> void:
	var temp = arr[from_idx]
	
	arr[from_idx] = arr[to_idx]
	arr[to_idx] = temp


static func array_flatv(arr : Array) -> Array:
	var ret = []
	
	for element in arr:
		assert(element is Array)
		
		ret.append_array(element)
	
	return ret


static func array_dictionary_hasv(arr : Array, keyvalarr : Array) -> bool:
	for element in arr:
		assert(element is Dictionary)

		for keyval in keyvalarr:
			assert(keyval is Dictionary)
			
			var tacc := 0
			var tsize = keyval.size()
			
			for key in keyval:
				var left = element.get(key, "")
				var right = keyval[key]
				
				if not typeof(left) == typeof(right):
					continue
					
				tacc += int(left == right)
				
				if tacc == tsize:
					return true
	
	return false


static func array_dictionary_popv(arr : Array, keyvallarr):
	var ret = array_dictionary_matchv(arr, keyvallarr)
	
	arr.erase(ret)
	
	return ret


static func array_dictionary_popallv(arr : Array, keyvalarr : Array) -> Array:
	var ret := array_dictionary_matchallv(arr, keyvalarr)
	
	for keyval in ret:
		arr.erase(keyval)
	
	return ret


static func array_dictionary_matchv(arr : Array, keyvalarr : Array):
	for element in arr:
		assert(element is Dictionary)
	
		for keyval in keyvalarr:
			assert(keyval is Dictionary)
			
			var tacc := 0
			var tsize = keyval.size()
			
			for key in keyval:
				var left = element.get(key, "")
				var right = keyval[key]
				
				if not typeof(left) == typeof(right):
					continue
				
				tacc += int(left == right)
			
			if tacc == tsize:
				return element


static func array_dictionary_matchallv(arr : Array, keyvalarr : Array) -> Array:
	var ret := []
	
	for element in arr:
		assert(element is Dictionary)
		
		for keyval in keyvalarr:
			assert(keyval is Dictionary)
			
			var tacc := 0
			
			var tsize = keyval.size()
			
			for key in keyval:
				var left = element.get(key, "")
				var right = keyval[key]
				
				if not typeof(left) == typeof(right):
					continue
					
				tacc += int(left == right)
					
			if tacc == tsize:
				ret.append(element)
	
	return ret


static func array_dictionary_findv(arr : Array, keyvalarr : Array) -> int:
	var i := 0
	
	for element in arr:
		assert(element is Dictionary)
	
		for keyval in keyvalarr:
			assert(keyval is Dictionary)
			
			var tacc := 0
			var tsize = keyval.size()
			
			for key in keyval:
				var left = element.get(key, "")
				var right = keyval[key]
				
				if not typeof(left) == typeof(right):
					continue
				
				tacc += int(left == right)
			
			if tacc == tsize:
				return i
	
		i += 1
	
	return -1


static func array_dictionary_count(arr : Array, key, value) -> int:
	var acc := 0
	
	for element in arr:
		assert(element is Dictionary)
		
		if element.get(key, "") == value:
			acc += 1
			
	return acc


static func control_centroid(c : Control) -> Vector2:
	return c.rect_size / 2


static func control_border_left(c : Control) -> PoolVector2Array:
	return PoolVector2Array([Vector2.ZERO, Vector2(0, c.rect_size.y)])
	
	
static func control_border_top(c : Control) -> PoolVector2Array:
	return PoolVector2Array([Vector2.ZERO, Vector2(c.rect_size.x, 0)])
	
	
static func control_border_right(c : Control) -> PoolVector2Array:
	return PoolVector2Array([Vector2(c.rect_size.x, 0), Vector2(c.rect_size.x, c.rect_size.y)])


static func control_border_bottom(c : Control) -> PoolVector2Array:
	return PoolVector2Array([Vector2(0, c.rect_size.y), Vector2(c.rect_size.x, c.rect_size.y)])


static func resolve(res_name : String) -> String:
	var ret := ""
	
	if _resolved_path_cache.has(res_name):
		ret = _resolved_path_cache[res_name]
	else:
		var f := File.new()
		var managed := [
			get_scene_dir(), 
			get_icon_dir(), 
			get_component_dir(),
			get_attachment_dir(),
			get_view_dir(),
			get_tool_dir(),
			"res://addons/GDEditor/Resources/Custom/"
		]
		
		for path in managed:
			var target = path + res_name
			if f.file_exists(target):
				_resolved_path_cache[res_name] = target
				ret = target
				break
		
		assert(not ret.empty(), "Could not resolve %s" % [res_name])
	
	return ret


static func add_state(key: String, value) -> void:
	_state[key] = value


static func clear_state() -> void:
	_state.clear()


static func filter_edit(rgx : RegEx, edit : LineEdit, rejected := "") -> void:
	var result := rgx.search(edit.text)
	
	if not result:
		edit.text = rejected
	else:
		edit.text = result.get_string()


static func line_centroidv(points : PoolVector2Array) -> Vector2:
	assert(points.size() == 2)
	var ret = points[1] + points[0]
	
	return ret/2
