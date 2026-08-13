extends Node

signal turn_end

signal character_died(Character)
signal target_selected(Character)
signal selected_move(Move)
signal hp_or_sp_changed()

signal speed_changed
signal started_defending(Player)
signal stoped_defending(Player)
signal enemy_cant_act(enemy:Monster)
signal action_done(actor:Character,move:Move,targets: Array) #compute move effectiveness from here and if damage_inflicted exists
signal not_enough_sp(actor:Character,Move)
signal attack_missed(target:Character)
signal damage_inflicted(damage:int, target : Character) #for healing, amount is fix so no need
signal status_proc(effect:Effect,target:Character)
signal status_stop(effect:Effect,target:Character)
signal dmg_from_poison(chara: Character,damage:int)

signal effect_to_copy(effect,chara)
signal negative_luck(unlucky)

signal selected_monster(Monster)
