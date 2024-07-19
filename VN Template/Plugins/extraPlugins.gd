@tool
extends EditorPlugin

func _enter_tree():
	pass


func _exit_tree():
	pass


func _has_main_screen():
	return true


func _make_visible(visible):
	pass


func _get_plugin_name():
	return "Main Screen Plugin"


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
