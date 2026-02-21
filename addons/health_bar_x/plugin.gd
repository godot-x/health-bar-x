@tool
extends EditorPlugin

func _enter_tree() -> void:
	var script_control = load("res://addons/health_bar_x/runtime/health_bar_x_control.gd") as Script
	var script_2d = load("res://addons/health_bar_x/runtime/health_bar_x_2d.gd") as Script
	if script_control == null or script_2d == null:
		push_error("HealthBarX: Failed to load runtime scripts.")
		return
	var icon: Texture2D = null
	if FileAccess.file_exists("res://addons/health_bar_x/icon.svg"):
		icon = load("res://addons/health_bar_x/icon.svg") as Texture2D
	add_custom_type("HealthBarXControl", "Control", script_control, icon)
	add_custom_type("HealthBarX2D", "Node2D", script_2d, icon)

func _exit_tree() -> void:
	remove_custom_type("HealthBarXControl")
	remove_custom_type("HealthBarX2D")
