@tool
@warning_ignore_start("unused_parameter")
class_name VisualShaderNodePolarToCartesian
extends VisualShaderNodeCustom


func _get_name() -> String:
	return "PolarToCartesian"


func _get_category() -> String:
	return "Vector/Common"


func _get_description() -> String:
	return "Converts Polar coordinates to Cartesian coordinates."


func _get_return_icon_type() -> PortType:
	return PORT_TYPE_VECTOR_2D


func _get_global_code(_mode: Shader.Mode) -> String:
	return """
vec2 polar_to_cartesian2(float angle, float dist) {
	return vec2(cos(angle), sin(angle)) * dist;
}
	"""


func _get_input_port_count() -> int:
	return 2


func _get_input_port_name(port: int) -> String:
	match port:
		0: return "angle"
		1: return "distance"
	return ""


func _get_input_port_type(port: int) -> PortType:
	return PORT_TYPE_SCALAR


func _get_input_port_default_value(port: int) -> Variant:
	match port:
		0: return 0.0
		1: return 0.0
	return 0


func _get_output_port_count() -> int:
	return 1


func _get_output_port_name(port: int) -> String:
	return "value"


func _get_output_port_type(port: int) -> PortType:
	return PORT_TYPE_VECTOR_2D


func _get_code(input_vars: Array[String], output_vars: Array[String], mode: Shader.Mode, type: VisualShader.Type) -> String:
	return output_vars[0] + " = polar_to_cartesian2(" + input_vars[0] + ", " + input_vars[1] + ");"
