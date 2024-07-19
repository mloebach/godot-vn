extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().change_char_image.connect(_changing_char_image)
	pass # Replace with function body.

func _changing_char_image(newChar):
	var newTexture = load(newChar)
	print(newChar)
	$SpriteImage.set_texture(newTexture)
	pass
