extends Reference

class_name GDUtil

enum {
	COMPONENT_DATA = 1
}

enum {
	CHARACTER_STATE_DATA_NAME,
	CHARACTER_STATE_DATA_VALUE
}


static func is_valid_type(instance : Object) -> bool:
	return instance.has_meta("value_type")


static func valid_type(instance : Object, type : int) -> bool:
	return is_valid_type(instance) and (get_type(instance) == type)


static func get_type(instance : Object) -> int:
	assert(is_valid_type(instance), "Instance is not a valid type")
	return instance.get_meta("value_type")
	
	
static func get_scene_dir() -> String:
	return "res://addons/GDEditor/Scenes/"
	
	
static func get_attachment_dir() -> String:
	return "res://addons/GDEditor/Scenes/Components/Attachments/"
	

static func array_swap_elementidx(arr : Array, from_idx : int, to_idx : int) -> void:
	var temp = arr[from_idx]
	arr[from_idx] = arr[to_idx]
	arr[to_idx] = temp


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
	

static func character_state_data(state_name : String, value = null) -> Dictionary:
	return {"name": state_name, "value": value}


static func character_state_data_key(state_property : int):
	match state_property:
		CHARACTER_STATE_DATA_NAME:
			return "name"
		CHARACTER_STATE_DATA_VALUE:
			return "value"


static func character_state_data_get(state_property : int, state_data : Dictionary):
	return state_data[character_state_data_key(state_property)]


static func character_state_data_set(state_property : int, state_data : Dictionary, value) -> void:
	match state_property:
		CHARACTER_STATE_DATA_NAME:
			state_data["name"] = value
		CHARACTER_STATE_DATA_VALUE:
			state_data["value"] = value
