extends Node2D

var firstScene = ProjectScenes.titleScreen


func _ready():
	print("loading first scene!")
	_swap_to_scene(firstScene)

func _swap_to_scene(scene):
	_deload_scenes()
	_load_scene(scene)

func _load_scene(scene):
	print("loading: " + str(scene))
	var sceneToLoad : Node = load(scene).instantiate()
	add_child(sceneToLoad)


func _deload_scenes():
	for n in $".".get_children():
		$".".remove_child(n)
		n.queue_free()
