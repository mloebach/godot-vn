extends Node2D

var storyScripts = {
	"tetoScene": "res://Text Scripts/testText.story",
	"secondScene": "res://Text Scripts/secondScene.story"
}

var background_dict = {
	"Blank": "res://Assets/Backgrounds/BlackBG.png",
	"LungmenRooftop": "res://Assets/Backgrounds/ArknightsRoof.png",
	"WeiRoom": "res://Assets/Backgrounds/WeiRoom.png"
}

var customVariables = {
	"bestBoy": "Boothill",
	"zenithName": "Zenithian",
	"defaultBG": "WeiRoom"
}



func getCustomVariables():
	return customVariables

func getBackgroundDict():
	return background_dict

func getStoryScript(scriptKey):
	if(!storyScripts.find_key(scriptKey)):
		print("specified key does not exist:" + scriptKey)
	return storyScripts[scriptKey]


