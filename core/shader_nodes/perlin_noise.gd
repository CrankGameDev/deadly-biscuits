@tool
@warning_ignore_start("unused_parameter")
class_name VisualShaderNodePerlinNoise
extends VisualShaderNodeCustom


func _get_name() -> String:
	return "PerlinNoise"


func _get_category() -> String:
	return "Utility"


func _get_description() -> String:
	return "Gets 2D Perlin Noise."


func _get_return_icon_type() -> PortType:
	return PORT_TYPE_SCALAR


func _get_global_code(_mode: Shader.Mode) -> String:
	return """
vec2 random2d(vec2 uv){
	uv = vec2(dot(uv, vec2(127.1,311.7)), dot(uv, vec2(269.5,183.3)));
	return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise2d(vec2 uv) {
	vec2 uv_index = floor(uv);
	vec2 uv_fract = fract(uv);
	vec2 blur = smoothstep(0.0, 1.0, uv_fract);
	return mix(
		mix(
			dot(random2d(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
			dot(random2d(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
			mix(
				dot(random2d(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
				dot(random2d(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x
			), 
			blur.y
		) + 0.5;
}
	"""


func _get_input_port_count() -> int:
	return 1


func _get_input_port_name(port: int) -> String:
	match port:
		0: return "uv"
	return ""


func _get_input_port_type(port: int) -> PortType:
	return PORT_TYPE_VECTOR_2D


func _get_input_port_default_value(port: int) -> Variant:
	match port:
		0: return Vector2.ZERO
	return 0


func _get_output_port_count() -> int:
	return 1


func _get_output_port_name(port: int) -> String:
	return "value"


func _get_output_port_type(port: int) -> PortType:
	return PORT_TYPE_SCALAR


func _get_code(input_vars: Array[String], output_vars: Array[String], mode: Shader.Mode, type: VisualShader.Type) -> String:
	return output_vars[0] + " = noise2d(" + input_vars[0] + ");"
