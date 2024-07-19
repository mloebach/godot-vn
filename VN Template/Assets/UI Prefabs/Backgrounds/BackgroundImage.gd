extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	
	get_parent().change_BG_image.connect(_changing_BG_image)
	pass # Replace with function body.

func _changing_BG_image(newBG):
	var newTexture = load(newBG)
	print(newBG)
	$BackgroundImage.set_texture(newTexture)
	pass
