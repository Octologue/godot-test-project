class_name TimelineManager
extends Node

var character_list : Array[Character]
var timeline : Array[Dictionary]


func initialize(ally_list : Array, enemy_list : Array ):
	character_list = ally_list+enemy_list
	for character in character_list:
		var delay : float = max(200 / log(character.agi + 2) - 25 , 1)
		for time in compute_queue(delay):
			timeline.append( {"character":character , "time":time} )
	timeline.sort_custom(sort_by_time)
	for i in timeline:
		print(i["character"].title," ",i["time"])
	
func compute_queue(delay : float):
	#create a queue from the delay value coming from a move or event
	var queue := []
	for i in range(8):
		if queue.is_empty():
			queue.append(delay)
		else:
			queue.append(queue[-1]+delay)
	return queue

func compute_move_delay(character:Character,move:Move):
	var delay : float = max( (200 / log(character.agi + 2) - 25)*move.delay , 1)
	return delay

func reset_character_queue(character : Character):
	timeline = timeline.filter(func(entry): return entry["character"] != character)

func get_actor():
	return timeline[0]["character"]

func pop_actor():
	timeline.pop_front()

func sort_by_time(a,b):
	return a["time"] < b["time"]
