extends Node2D

var firstScene = ProjectScenes.titleScreen
@export_file("*.story") var startingScript

func _ready():
	print("loading first scene!")
	_load_title()

func _swap_to_scene(scene):
	_deload_scenes()
	var new_scene : Node = _load_scene(scene)
	return new_scene

func _load_scene(scene):
	print("loading: " + str(scene))
	var sceneToLoad : Node = load(scene).instantiate()
	add_child(sceneToLoad)
	return sceneToLoad

func _load_title():
	var new_scene : Node = _swap_to_scene(ProjectScenes.titleScreen)
	new_scene.move_to_vn.connect(_to_load_vn_pressed)

func _load_vn():
	_load_vn_scene(startingScript)

func _load_vn_scene(scriptFile=null, section = null):
	var new_scene : Node = _swap_to_scene(ProjectScenes.vnScene)
	match scriptFile:
		null:
			new_scene.scriptToLoad = startingScript
		_:
			new_scene.scriptToLoad = scriptFile
	new_scene.startingSection = section
	new_scene._loadScript()
	new_scene.move_to_title.connect(_to_load_title_pressed)
	new_scene.move_to_gameplay.connect(_to_load_gameplay_pressed)
	
func _load_gameplay():
	var new_scene : Node = _swap_to_scene(ProjectScenes.gameplayScene)
	new_scene.move_to_vn.connect(_to_load_vn_pressed)
	new_scene.move_to_vn_scene.connect(_to_load_vn_scene_pressed)

func _to_load_vn_pressed():
	_load_vn()
	
func _to_load_vn_scene_pressed(scene=null, section=null):
	_load_vn_scene(scene, section)
	
func _to_load_title_pressed():
	_load_title()
	
func _to_load_gameplay_pressed():
	_load_gameplay()

func _deload_scenes():
	for n in $".".get_children():
		$".".remove_child(n)
		n.queue_free()
