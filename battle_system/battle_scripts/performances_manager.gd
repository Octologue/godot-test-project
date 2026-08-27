class_name PerformancesManager
extends Node

var performances : Array[Dictionary]

func performances_init(ally_list):
	for ally in ally_list:
		performances.append({
			"ally":ally,
			"damage": 0,
			"healing":0,
			"status":0,
			"killed":0,
		})
	

func add_performance(action_result:BattleActionResult):
	pass
