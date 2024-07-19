extends Node

@export_multiline var testPhrase: String
var headAlphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R"]
var tailAlphabet = ["S", "T", "U", "V", "W", "X", "Y", "Z"]

# Called when the node enters the scene tree for the first time.
func _ready():
	var translatedString = _translate_to_aquolion(testPhrase)
	print("[b]Translating...[/b]")
	print(testPhrase + " is:")
	print_rich(translatedString)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Here’s a sentence so that you can give me something in Uelgwold speak!
func _translate_to_aquolion(passedText):
	var translatedText = _replace_punctuation(passedText).to_lower().split(" ")
	var eachWordValue: Array
	var eachWordLength: Array
	print("translated text:" + str(translatedText))
	for word in translatedText:
		eachWordValue.append(_get_word_value(word))
		eachWordLength.append(word.length())
	print("each word value:" + str(eachWordValue))
	print("each word length:" + str(eachWordLength))
	
	var finalString = ""
	for number in eachWordValue.size():
		finalString += _numbers_to_words(eachWordValue[number], eachWordLength[number]) + " "
	return finalString
	pass
	
func _replace_punctuation(passedText):
	var regex = RegEx.new()
	regex.compile("[^a-zA-Z0-9 -]");

	return regex.sub(passedText, "", true)

func _get_word_value(word):
	var valueSum = 0
	for n in word.length():
		var asciiPosition = word[n].to_ascii_buffer()[0]
		#a = 97, z=122. subtract 96
		if(asciiPosition > 96 && asciiPosition < 123):
			asciiPosition -= 96
		#0 = 48, 1=49....9=57
		elif(asciiPosition > 47 && asciiPosition < 58):
			asciiPosition -= 48
		var char = (asciiPosition)
		print("ascii position of first letter " + word[n] + " is: " + str(char))
		valueSum += char
	print("value of " + word + " is " + str(valueSum))
	return valueSum
	
	
func _numbers_to_words(value, length):
	#digit 1 - value / 18
	#digit 2 - value % 18 (aka 1-2 is base 18)
	#digit 3 - length / 8
	#digit 4 - length % 8
	
	var newWord = ""
	if(value > headAlphabet.size()):
		var numberToSend = value / headAlphabet.size()
		if(value %headAlphabet.size() == 0):
			numberToSend -= 1
		newWord += _alphabet_table_head(numberToSend)
	newWord += _alphabet_table_head(value % headAlphabet.size())	
	
	if(length > tailAlphabet.size()):
		var numberToSend = length / tailAlphabet.size()
		if(length % tailAlphabet.size() == 0):
			numberToSend -= 1
		newWord += _alphabet_table_tail(numberToSend)
	newWord += _alphabet_table_tail(length % tailAlphabet.size())
	
	return newWord
	
func _alphabet_table_head(number):
	if(number <= headAlphabet.size()):
		return headAlphabet[number-1]
	else:
		print("Head: Number too large or other error")
		return "?"
		

func _alphabet_table_tail(number):
	if(number <= tailAlphabet.size()):
		return tailAlphabet[number-1]
	else:
		print("Tail: Number too large or other error")
		return "?"
