tool
extends Reference



# Declarations
export(String) var name := ""



# Core
func select(editor, event : InputEventMouse, prev_hit : Dictionary) -> Dictionary:
	return {
		"work": false,
		"consume": true,
		"selection": []
	}