extends Node2D

var current_text : String
var turn_count : int = 0
var battle_log : Dictionary

func _ready() :
	BattleEvent.started_defending.connect(_on_started_defending)
	BattleEvent.stoped_defending.connect(_on_stoped_defending)
	BattleEvent.enemy_cant_act.connect(_on_enemy_cant_act)
	BattleEvent.action_done.connect(_on_action_done)
	BattleEvent.not_enough_sp.connect(_on_not_enough_sp)
	BattleEvent.attack_missed.connect(_on_attack_missed)
	BattleEvent.damage_inflicted.connect(_on_damage_inflicted)
	BattleEvent.status_proc.connect(_on_status_proc)
	BattleEvent.status_stop.connect(_on_status_stop)
	BattleEvent.dmg_from_poison.connect(_on_dmg_from_poison)
	BattleEvent.character_died_log.connect(_on_character_died_log)

func new_turn():
	turn_count += 1
	battle_log[turn_count] = current_text
	current_text = "Turn " + str(turn_count) + "\n"

func show_current_text():
	print(current_text)

func create_log_text():
	var text = ""
	if battle_log.is_empty():
		return text
	for turn in battle_log:
		text += battle_log[turn] + "\n\n"
	return text

func _on_started_defending(player:Player):
	current_text += player.title+ " started defending!\n"

func _on_stoped_defending(player:Player):
	current_text += player.title+ " stopped defending!\n"

func _on_enemy_cant_act(enemy:Monster):
	current_text += enemy.title + " has no possible move!\n"

func _on_action_done(actor:Character,move:Move,targets: Array):
	match move.move_range:
		move.Ranges.SELF:
			current_text += actor.title + " used " + move.title + "!\n"
		move.Ranges.ENEMY, move.Ranges.ALLY:
			current_text += actor.title + " used " + move.title + " on " + targets[0].title + "!\n"
		move.Ranges.ENEMIES:
			current_text += actor.title + " used " + move.title + " on all enemies!\n"
		move.Ranges.ALLIES:
			current_text += actor.title + " used " + move.title + " on all allies!\n"
		move.Ranges.ALL:
			current_text += actor.title + " used " + move.title + " on everyone on the field!\n"
		move.Ranges.R_ENEMY:
			current_text += actor.title + " used " + move.title + " on random enemies!\n"
	
	if move.category == move.Categories.MELEE or move.Categories.RANGED:
		var weaks = []
		var resists = []
		for t in targets:
			if move.type in t.weaknesses:
				weaks.append(t)
			elif move.type in t.resistances:
				resists.append(t)
		if weaks.size() == 1:
			current_text += "This is super effective! "
		if weaks.size()> 1:
			current_text += "This is super effective on "
			for w in weaks:
				if w == weaks[-1]:
					current_text += " and " + w.title + "!\n"
				else: 
					current_text += w.title + ","
		if resists.size() == 1:
			current_text += "This isn't very effective... "
		if resists.size()> 1:
			current_text += "This isn't very effective on "
			for r in resists:
				if r == weaks[-1]:
					current_text += " and " + r.title + "...\n"
				else:
					current_text += r.title + ","
			

func _on_damage_inflicted(damage:int, target: Character):
	current_text += target.title + " took " + str(damage) + " damage and now has " + str(target.hp) + " HP.\n"
	
func _on_attack_missed(target:Character):
	current_text += target.title + " dodged!\n"

func _on_not_enough_sp(actor:Character,move:Move):
	current_text += actor.title + " doesn't have enough SP to cast " + move.title +"...\n"

func _on_character_died_log(chara : Character):
	current_text += chara.title + " died!\n"

func _on_status_proc(effect:Effect,target:Character):
	current_text+= target.title + " is affected by " + effect.title + ".\n"

func _on_status_stop(effect:Effect,target:Character):
	current_text+= target.title + " is no longer affect by " + effect.title + ".\n"

func _on_dmg_from_poison(chara:Character,damage:int):
	current_text+= chara.title + " is poisoned and lose "+ str(damage)+ "HP.\n"
