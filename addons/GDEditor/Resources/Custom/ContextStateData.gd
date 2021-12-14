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
export(Array) var state_value
export(int) var state_type
