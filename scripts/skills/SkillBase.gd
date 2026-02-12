extends Node2D

# ============ 技能系统基类 ============

class_name SkillBase extends Node

var skill_name: String = "技能"
var description: String = ""
var cooldown: float = 1.0
var last_use_time: float = -10.0
var mana_cost: int = 0
var level: int = 1

func _init():
	pass

func can_use() -> bool:
	var now = Time.get_ticks_msec() / 1000.0
	return now - last_use_time >= cooldown

func activate(user: Node2D, target: Vector2 = Vector2.ZERO) -> bool:
	if not can_use():
		return false
	
	last_use_time = Time.get_ticks_msec() / 1000.0
	_perform_skill(user, target)
	return true

func _perform_skill(user: Node2D, target: Vector2) -> void:
	print("%s 释放!" % skill_name)

func level_up() -> void:
	level += 1
	cooldown = max(0.5, cooldown * 0.9)
	print("%s 升级到 %d 级!" % [skill_name, level])
