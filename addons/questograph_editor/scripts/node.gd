@tool
extends Resource
class_name QuestographEditorSettings

@export var actions: Array[QuestographEditorNodeSettings]:
	set(value):
		for index in range(value.size()):
			if not value[index]:
				value[index] = QuestographEditorNodeSettings.new()
				value[index].resource_name = 'Action Settings'
		actions = value


#[
	#{ "name": "var_string", "class_name": &"", "type": 4, "hint": 0, "hint_string": "String", "usage": 4102 },
	#{ "name": "var_integer", "class_name": &"", "type": 2, "hint": 0, "hint_string": "int", "usage": 4102 },
	#{ "name": "var_float", "class_name": &"", "type": 3, "hint": 0, "hint_string": "float", "usage": 4102 },
	#{ "name": "var_bool", "class_name": &"", "type": 1, "hint": 0, "hint_string": "bool", "usage": 4102 }
#]


#enum  PropertyHint:
#
#● PROPERTY_HINT_NONE = 0
#The property has no hint for the editor.
#● PROPERTY_HINT_RANGE = 1
#Hints that an int or float property should be within a range specified via the hint string "min,max" or "min,max,step". The hint string can optionally include "or_greater" and/or "or_less" to allow manual input going respectively above the max or below the min values.
#
#Example: "-360,360,1,or_greater,or_less".
#
#Additionally, other keywords can be included: "exp" for exponential range editing, "radians_as_degrees" for editing radian angles in degrees (the range values are also in degrees), "degrees" to hint at an angle and "hide_slider" to hide the slider.
#
#● PROPERTY_HINT_ENUM = 2
#Hints that an int or String property is an enumerated value to pick in a list specified via a hint string.
#
#The hint string is a comma separated list of names such as "Hello,Something,Else". Whitespaces are not removed from either end of a name. For integer properties, the first name in the list has value 0, the next 1, and so on. Explicit values can also be specified by appending :integer to the name, e.g. "Zero,One,Three:3,Four,Six:6".
#
#● PROPERTY_HINT_ENUM_SUGGESTION = 3
#Hints that a String property can be an enumerated value to pick in a list specified via a hint string such as "Hello,Something,Else".
#
#Unlike PROPERTY_HINT_ENUM, a property with this hint still accepts arbitrary values and can be empty. The list of values serves to suggest possible values.
#
#● PROPERTY_HINT_EXP_EASING = 4
#Hints that a float property should be edited via an exponential easing function. The hint string can include "attenuation" to flip the curve horizontally and/or "positive_only" to exclude in/out easing and limit values to be greater than or equal to zero.
#● PROPERTY_HINT_LINK = 5
#Hints that a vector property should allow its components to be linked. For example, this allows Vector2.x and Vector2.y to be edited together.
#● PROPERTY_HINT_FLAGS = 6
#Hints that an int property is a bitmask with named bit flags.
#
#The hint string is a comma separated list of names such as "Bit0,Bit1,Bit2,Bit3". Whitespaces are not removed from either end of a name. The first name in the list has value 1, the next 2, then 4, 8, 16 and so on. Explicit values can also be specified by appending :integer to the name, e.g. "A:4,B:8,C:16". You can also combine several flags ("A:4,B:8,AB:12,C:16").
#
#Note: A flag value must be at least 1 and at most 2 ** 32 - 1.
#
#Note: Unlike PROPERTY_HINT_ENUM, the previous explicit value is not taken into account. For the hint "A:16,B,C", A is 16, B is 2, C is 4.
#
#● PROPERTY_HINT_LAYERS_2D_RENDER = 7
#Hints that an int property is a bitmask using the optionally named 2D render layers.
#● PROPERTY_HINT_LAYERS_2D_PHYSICS = 8
#Hints that an int property is a bitmask using the optionally named 2D physics layers.
#● PROPERTY_HINT_LAYERS_2D_NAVIGATION = 9
#Hints that an int property is a bitmask using the optionally named 2D navigation layers.
#● PROPERTY_HINT_LAYERS_3D_RENDER = 10
#Hints that an int property is a bitmask using the optionally named 3D render layers.
#● PROPERTY_HINT_LAYERS_3D_PHYSICS = 11
#Hints that an int property is a bitmask using the optionally named 3D physics layers.
#● PROPERTY_HINT_LAYERS_3D_NAVIGATION = 12
#Hints that an int property is a bitmask using the optionally named 3D navigation layers.
#● PROPERTY_HINT_LAYERS_AVOIDANCE = 37
#Hints that an integer property is a bitmask using the optionally named avoidance layers.
#● PROPERTY_HINT_FILE = 13
#Hints that a String property is a path to a file. Editing it will show a file dialog for picking the path. The hint string can be a set of filters with wildcards like "*.png,*.jpg".
#● PROPERTY_HINT_DIR = 14
#Hints that a String property is a path to a directory. Editing it will show a file dialog for picking the path.
#● PROPERTY_HINT_GLOBAL_FILE = 15
#Hints that a String property is an absolute path to a file outside the project folder. Editing it will show a file dialog for picking the path. The hint string can be a set of filters with wildcards, like "*.png,*.jpg".
#● PROPERTY_HINT_GLOBAL_DIR = 16
#Hints that a String property is an absolute path to a directory outside the project folder. Editing it will show a file dialog for picking the path.
#● PROPERTY_HINT_RESOURCE_TYPE = 17
#Hints that a property is an instance of a Resource-derived type, optionally specified via the hint string (e.g. "Texture2D"). Editing it will show a popup menu of valid resource types to instantiate.
#● PROPERTY_HINT_MULTILINE_TEXT = 18
#Hints that a String property is text with line breaks. Editing it will show a text input field where line breaks can be typed.
#● PROPERTY_HINT_EXPRESSION = 19
#Hints that a String property is an Expression.
#● PROPERTY_HINT_PLACEHOLDER_TEXT = 20
#Hints that a String property should show a placeholder text on its input field, if empty. The hint string is the placeholder text to use.
#● PROPERTY_HINT_COLOR_NO_ALPHA = 21
#Hints that a Color property should be edited without affecting its transparency (Color.a is not editable).
#● PROPERTY_HINT_OBJECT_ID = 22
#Hints that the property's value is an object encoded as object ID, with its type specified in the hint string. Used by the debugger.
#● PROPERTY_HINT_TYPE_STRING = 23
#If a property is String, hints that the property represents a particular type (class). This allows to select a type from the create dialog. The property will store the selected type as a string.
#
#If a property is Array, hints the editor how to show elements. The hint_string must encode nested types using ":" and "/".
#
## Array of elem_type.
#hint_string = "%d:" % [elem_type]
#hint_string = "%d/%d:%s" % [elem_type, elem_hint, elem_hint_string]
## Two-dimensional array of elem_type (array of arrays of elem_type).
#hint_string = "%d:%d:" % [TYPE_ARRAY, elem_type]
#hint_string = "%d:%d/%d:%s" % [TYPE_ARRAY, elem_type, elem_hint, elem_hint_string]
## Three-dimensional array of elem_type (array of arrays of arrays of elem_type).
#hint_string = "%d:%d:%d:" % [TYPE_ARRAY, TYPE_ARRAY, elem_type]
#hint_string = "%d:%d:%d/%d:%s" % [TYPE_ARRAY, TYPE_ARRAY, elem_type, elem_hint, elem_hint_string]
#
#Examples:
#
#hint_string = "%d:" % [TYPE_INT] # Array of integers.
#hint_string = "%d/%d:1,10,1" % [TYPE_INT, PROPERTY_HINT_RANGE] # Array of integers (in range from 1 to 10).
#hint_string = "%d/%d:Zero,One,Two" % [TYPE_INT, PROPERTY_HINT_ENUM] # Array of integers (an enum).
#hint_string = "%d/%d:Zero,One,Three:3,Six:6" % [TYPE_INT, PROPERTY_HINT_ENUM] # Array of integers (an enum).
#hint_string = "%d/%d:*.png" % [TYPE_STRING, PROPERTY_HINT_FILE] # Array of strings (file paths).
#hint_string = "%d/%d:Texture2D" % [TYPE_OBJECT, PROPERTY_HINT_RESOURCE_TYPE] # Array of textures.
#
#hint_string = "%d:%d:" % [TYPE_ARRAY, TYPE_FLOAT] # Two-dimensional array of floats.
#hint_string = "%d:%d/%d:" % [TYPE_ARRAY, TYPE_STRING, PROPERTY_HINT_MULTILINE_TEXT] # Two-dimensional array of multiline strings.
#hint_string = "%d:%d/%d:-1,1,0.1" % [TYPE_ARRAY, TYPE_FLOAT, PROPERTY_HINT_RANGE] # Two-dimensional array of floats (in range from -1 to 1).
#hint_string = "%d:%d/%d:Texture2D" % [TYPE_ARRAY, TYPE_OBJECT, PROPERTY_HINT_RESOURCE_TYPE] # Two-dimensional array of textures.
#
#Note: The trailing colon is required for properly detecting built-in types.
#
#● PROPERTY_HINT_NODE_PATH_TO_EDITED_NODE = 24   (Deprecated)
#Deprecated. This hint is not used anywhere and will be removed in the future.
#● PROPERTY_HINT_OBJECT_TOO_BIG = 25
#Hints that an object is too big to be sent via the debugger.
#● PROPERTY_HINT_NODE_PATH_VALID_TYPES = 26
#Hints that the hint string specifies valid node types for property of type NodePath.
#● PROPERTY_HINT_SAVE_FILE = 27
#Hints that a String property is a path to a file. Editing it will show a file dialog for picking the path for the file to be saved at. The dialog has access to the project's directory. The hint string can be a set of filters with wildcards like "*.png,*.jpg". See also FileDialog.filters.
#● PROPERTY_HINT_GLOBAL_SAVE_FILE = 28
#Hints that a String property is a path to a file. Editing it will show a file dialog for picking the path for the file to be saved at. The dialog has access to the entire filesystem. The hint string can be a set of filters with wildcards like "*.png,*.jpg". See also FileDialog.filters.
#● PROPERTY_HINT_INT_IS_OBJECTID = 29   (Deprecated)
#Hints that an int property is an object ID.
#
#Deprecated. This hint is not used anywhere and will be removed in the future.
#
#● PROPERTY_HINT_INT_IS_POINTER = 30
#Hints that an int property is a pointer. Used by GDExtension.
#● PROPERTY_HINT_ARRAY_TYPE = 31
#Hints that a property is an Array with the stored type specified in the hint string.
#● PROPERTY_HINT_LOCALE_ID = 32
#Hints that a string property is a locale code. Editing it will show a locale dialog for picking language and country.
#● PROPERTY_HINT_LOCALIZABLE_STRING = 33
#Hints that a dictionary property is string translation map. Dictionary keys are locale codes and, values are translated strings.
#● PROPERTY_HINT_NODE_TYPE = 34
#Hints that a property is an instance of a Node-derived type, optionally specified via the hint string (e.g. "Node2D"). Editing it will show a dialog for picking a node from the scene.
#● PROPERTY_HINT_HIDE_QUATERNION_EDIT = 35
#Hints that a quaternion property should disable the temporary euler editor.
#● PROPERTY_HINT_PASSWORD = 36
#Hints that a string property is a password, and every character is replaced with the secret character.
#● PROPERTY_HINT_MAX = 38
#Represents the size of the PropertyHint enum.

#flags  PropertyUsageFlags:
#
#● PROPERTY_USAGE_NONE = 0
#The property is not stored, and does not display in the editor. This is the default for non-exported properties.
#● PROPERTY_USAGE_STORAGE = 2
#The property is serialized and saved in the scene file (default).
#● PROPERTY_USAGE_EDITOR = 4
#The property is shown in the EditorInspector (default).
#● PROPERTY_USAGE_INTERNAL = 8
#The property is excluded from the class reference.
#● PROPERTY_USAGE_CHECKABLE = 16
#The property can be checked in the EditorInspector.
#● PROPERTY_USAGE_CHECKED = 32
#The property is checked in the EditorInspector.
#● PROPERTY_USAGE_GROUP = 64
#Used to group properties together in the editor. See EditorInspector.
#● PROPERTY_USAGE_CATEGORY = 128
#Used to categorize properties together in the editor.
#● PROPERTY_USAGE_SUBGROUP = 256
#Used to group properties together in the editor in a subgroup (under a group). See EditorInspector.
#● PROPERTY_USAGE_CLASS_IS_BITFIELD = 512
#The property is a bitfield, i.e. it contains multiple flags represented as bits.
#● PROPERTY_USAGE_NO_INSTANCE_STATE = 1024
#The property does not save its state in PackedScene.
#● PROPERTY_USAGE_RESTART_IF_CHANGED = 2048
#Editing the property prompts the user for restarting the editor.
#● PROPERTY_USAGE_SCRIPT_VARIABLE = 4096
#The property is a script variable which should be serialized and saved in the scene file.
#● PROPERTY_USAGE_STORE_IF_NULL = 8192
#The property value of type Object will be stored even if its value is null.
#● PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED = 16384
#If this property is modified, all inspector fields will be refreshed.
#● PROPERTY_USAGE_SCRIPT_DEFAULT_VALUE = 32768   (Deprecated)
#Signifies a default value from a placeholder script instance.
#
#Deprecated. This hint is not used anywhere and will be removed in the future.
#
#● PROPERTY_USAGE_CLASS_IS_ENUM = 65536
#The property is an enum, i.e. it only takes named integer constants from its associated enumeration.
#● PROPERTY_USAGE_NIL_IS_VARIANT = 131072
#If property has nil as default value, its type will be Variant.
#● PROPERTY_USAGE_ARRAY = 262144
#The property is an array.
#● PROPERTY_USAGE_ALWAYS_DUPLICATE = 524288
#When duplicating a resource with Resource.duplicate(), and this flag is set on a property of that resource, the property should always be duplicated, regardless of the subresources bool parameter.
#● PROPERTY_USAGE_NEVER_DUPLICATE = 1048576
#When duplicating a resource with Resource.duplicate(), and this flag is set on a property of that resource, the property should never be duplicated, regardless of the subresources bool parameter.
#● PROPERTY_USAGE_HIGH_END_GFX = 2097152
#The property is only shown in the editor if modern renderers are supported (the Compatibility rendering method is excluded).
#● PROPERTY_USAGE_NODE_PATH_FROM_SCENE_ROOT = 4194304
#The NodePath property will always be relative to the scene's root. Mostly useful for local resources.
#● PROPERTY_USAGE_RESOURCE_NOT_PERSISTENT = 8388608
#Use when a resource is created on the fly, i.e. the getter will always return a different instance. ResourceSaver needs this information to properly save such resources.
#● PROPERTY_USAGE_KEYING_INCREMENTS = 16777216
#Inserting an animation key frame of this property will automatically increment the value, allowing to easily keyframe multiple values in a row.
#● PROPERTY_USAGE_DEFERRED_SET_RESOURCE = 33554432   (Deprecated)
#When loading, the resource for this property can be set at the end of loading.
#
#Deprecated. This hint is not used anywhere and will be removed in the future.
#
#● PROPERTY_USAGE_EDITOR_INSTANTIATE_OBJECT = 67108864
#When this property is a Resource and base object is a Node, a resource instance will be automatically created whenever the node is created in the editor.
#● PROPERTY_USAGE_EDITOR_BASIC_SETTING = 134217728
#The property is considered a basic setting and will appear even when advanced mode is disabled. Used for project settings.
#● PROPERTY_USAGE_READ_ONLY = 268435456
#The property is read-only in the EditorInspector.
#● PROPERTY_USAGE_SECRET = 536870912
#An export preset property with this flag contains confidential information and is stored separately from the rest of the export preset configuration.
#● PROPERTY_USAGE_DEFAULT = 6
#Default usage (storage and editor).
#● PROPERTY_USAGE_NO_EDITOR = 2
#Default usage but without showing the property in the editor (storage).


#enum  Variant.Type:
#
#● TYPE_NIL = 0
#Variable is null.
#● TYPE_BOOL = 1
#Variable is of type bool.
#● TYPE_INT = 2
#Variable is of type int.
#● TYPE_FLOAT = 3
#Variable is of type float.
#● TYPE_STRING = 4
#Variable is of type String.
#● TYPE_VECTOR2 = 5
#Variable is of type Vector2.
#● TYPE_VECTOR2I = 6
#Variable is of type Vector2i.
#● TYPE_RECT2 = 7
#Variable is of type Rect2.
#● TYPE_RECT2I = 8
#Variable is of type Rect2i.
#● TYPE_VECTOR3 = 9
#Variable is of type Vector3.
#● TYPE_VECTOR3I = 10
#Variable is of type Vector3i.
#● TYPE_TRANSFORM2D = 11
#Variable is of type Transform2D.
#● TYPE_VECTOR4 = 12
#Variable is of type Vector4.
#● TYPE_VECTOR4I = 13
#Variable is of type Vector4i.
#● TYPE_PLANE = 14
#Variable is of type Plane.
#● TYPE_QUATERNION = 15
#Variable is of type Quaternion.
#● TYPE_AABB = 16
#Variable is of type AABB.
#● TYPE_BASIS = 17
#Variable is of type Basis.
#● TYPE_TRANSFORM3D = 18
#Variable is of type Transform3D.
#● TYPE_PROJECTION = 19
#Variable is of type Projection.
#● TYPE_COLOR = 20
#Variable is of type Color.
#● TYPE_STRING_NAME = 21
#Variable is of type StringName.
#● TYPE_NODE_PATH = 22
#Variable is of type NodePath.
#● TYPE_RID = 23
#Variable is of type RID.
#● TYPE_OBJECT = 24
#Variable is of type Object.
#● TYPE_CALLABLE = 25
#Variable is of type Callable.
#● TYPE_SIGNAL = 26
#Variable is of type Signal.
#● TYPE_DICTIONARY = 27
#Variable is of type Dictionary.
#● TYPE_ARRAY = 28
#Variable is of type Array.
#● TYPE_PACKED_BYTE_ARRAY = 29
#Variable is of type PackedByteArray.
#● TYPE_PACKED_INT32_ARRAY = 30
#Variable is of type PackedInt32Array.
#● TYPE_PACKED_INT64_ARRAY = 31
#Variable is of type PackedInt64Array.
#● TYPE_PACKED_FLOAT32_ARRAY = 32
#Variable is of type PackedFloat32Array.
#● TYPE_PACKED_FLOAT64_ARRAY = 33
#Variable is of type PackedFloat64Array.
#● TYPE_PACKED_STRING_ARRAY = 34
#Variable is of type PackedStringArray.
#● TYPE_PACKED_VECTOR2_ARRAY = 35
#Variable is of type PackedVector2Array.
#● TYPE_PACKED_VECTOR3_ARRAY = 36
#Variable is of type PackedVector3Array.
#● TYPE_PACKED_COLOR_ARRAY = 37
#Variable is of type PackedColorArray.
#● TYPE_MAX = 38
#Represents the size of the Variant.Type enum.
