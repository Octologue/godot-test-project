class_name TimelineManager
extends Node

var battle_timeline : Array[Dictionary]
var current_time := 0.0

func initialize(ally_list,enemy_list):
	var character_list = ally_list.duplicate() + enemy_list.duplicate()
	for character in character_list:
		var delay : float = max(200 / log(character.agi+2) - 25 , 1)
		for time in create_queue(delay):
			battle_timeline.append({"character":character,"time":time})
	sort_timeline(battle_timeline)
	print_timeline()

func on_move_used(actor:Character,move:Move):
	
	update_current_time()
	
	battle_timeline = reset_character_from_timeline(actor,battle_timeline)
	
	var delay = max(200 / log(actor.agi+2) - 25 , 1) * move.delay_mult
	
	for time in create_queue(delay):
		battle_timeline.append({"character":actor,"time":time})

	sort_timeline(battle_timeline)
	
	if actor == get_actor():
		pop_actor()
	
	print_timeline()
	
func create_queue(delay:float):
	var queue := []
	for i in range(1,9):
		queue.append(current_time + delay*i)
	return queue

func reset_character_from_timeline(character:Character,timeline:Array[Dictionary]):
	return timeline.filter(func(entry): return entry["character"] != character)

func sort_timeline(timeline:Array[Dictionary]):
	timeline.sort_custom(sort_by_time)

func sort_by_time(a,b):
	return a["time"] < b["time"]

func update_current_time():
	current_time = battle_timeline[0]["time"]

func get_actor():
	return battle_timeline[0]["character"]

func pop_actor():
	battle_timeline.pop_front()

func print_timeline():
	return
	print("TIMELINE : ")
	for i in battle_timeline:
		print (i["character"].title," : ",i["time"])
