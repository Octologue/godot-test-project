class_name BattleTarget
extends Node

var target : Character
var missed : bool = false
var damage : int = 0
var can_kill : bool = false
var kill : bool = false
var weakness : Weakness
enum Weakness {NEUTRAL,WEAK,RESIST}
var crit : bool = false
var stab : bool = false
var effects : Array[Effect] #if effects.size > 0 then move did proc
