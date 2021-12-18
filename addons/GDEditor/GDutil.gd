extends Reference

class_name GDUtil

enum {
	COMPONENT_DATA = 1
}

enum {
	CHARACTER_STATE_DATA_NAME,
	CHARACTER_STATE_DATA_VALUE
}

const _state := {}
const _resolved_path_cache := {}


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
			get_attachment_dir()
		]
		
		for path in managed:
			var target = path + res_name
			if f.file_exists(target):
				_resolved_path_cache[res_name] = target
				ret = target
				break
			
		
		assert(not ret.empty(), "Could not resolve %s" % [res_name])
	
	return ret


static func add_state(key : String, value) -> void:
	_state[key] = value
	

static func erase_state(key : String) -> void:
	_state.erase(key)


static func is_valid_type(instance : Object) -> bool:
	return instance.has_meta("value_type")


static func valid_type(instance : Object, type : int) -> bool:
	return is_valid_type(instance) and (get_type(instance) == type)


static func get_type(instance : Object) -> int:
	assert(is_valid_type(instance), "Instance is not a valid type")
	return instance.get_meta("value_type")
	
	
static func get_scene_dir() -> String:
	return "res://addons/GDEditor/Scenes/"
	
	
static func get_component_dir() -> String:
	return"res://addons/GDEditor/Scenes/Components/"

	
static func get_attachment_dir() -> String:
	return "res://addons/GDEditor/Scenes/Components/Attachments/"
	
	
static func get_icon_dir() -> String:
	return "res://addons/GDEditor/Resources/Icons/"
	

static func get_icon(icon_name : String) -> Texture:
	var ret : Texture
	
	if _state.has("editor_interface"):
		ret = _state["editor_interface"].get_base_control().get_icon(icon_name, "EditorIcons")
	else:
		# All icons has to be a .png
		ret = load(resolve(icon_name + ".png")) as Texture
		
	return ret
	
	
static func regex_match(s : String, rgx : RegEx) -> bool:
	var result := rgx.search(s)
	
	if not result:
		return false
	else:	
		return s == result.get_string()
	

static func array_swap_elementidx(arr : Array, from_idx : int, to_idx : int) -> void:
	var temp = arr[from_idx]
	arr[from_idx] = arr[to_idx]
	arr[to_idx] = temp


static func array_flatv(arr : Array) -> Array:
	var ret = []
	for element in arr:
		assert(Array(element) is Array)
		ret.append_array(element)
	
	return ret


static func array_dictionary_has(arr : Array, key, value) -> bool:
	for element in arr:
		assert(element is Dictionary)
		assert(key in element)
		
		if element.get(key, "") == value:
			return true
	
	return false
	

static func array_dictionary_find(arr : Array, key, value):
	for element in arr:
		assert(element is Dictionary)
		assert(key in element)
		
		if element.get(key, "") == value:
			return element
	
	
static func array_dictionary_count(arr : Array, key, value) -> int:
	var acc := 0
	
	for element in arr:
		assert(element is Dictionary)
		assert(key in element)
		
		if element.get(key, "") == value:
			acc += 1
			
	return acc


static func array_dictionary_match(arr : Array, key, value : String) -> int:
	var acc := 0
	
	for element in arr:
		assert(element is Dictionary)
		assert(key in element)
		
		if value.is_subsequence_of(element[key]):
			acc += 1
			
	return acc


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
