@tool
extends EditorPlugin


var dock = preload("res://addons/plugin_test/HelloButtonPlugin.tscn").instantiate()

var main_panel_instance


func _enter_tree():
	#main_panel_instance = dock.instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_BL, dock)
	# Add the main panel to the editor's main viewport.
	#EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	#_make_visible(false)


func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()
	#if main_panel_instance:
	#	main_panel_instance.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func _get_plugin_name():
	return "Main Screen Plugin"


func _get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
