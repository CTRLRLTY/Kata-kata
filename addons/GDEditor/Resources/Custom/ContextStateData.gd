extends Resource

class_name ContextStateData

enum {
	TYPE_STRING,
	TYPE_BOOL,
	TYPE_INT,
	TYPE_FLOAT
}

# The state_value is implicitly implied to be homogeneous. 
#	 The value will always be wrapped in an array, no matter what type.
export var state_name : String
export var state_value : Array
export var state_type : int


func is_array() -> bool:
	return state_value.size() > 1
