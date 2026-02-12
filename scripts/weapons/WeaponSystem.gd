extends Node2D

# ============ 武器系统基类 ============
# 扩展方式：继承并重写相关方法

class_name WeaponSystem extends Node

# 属性
var weapon_name: String = "武器"
var damage: int = 1
var attack_range: float = 50.0
var attack_cooldown: float = 0.5
var last_attack_time: float = 0.0

# 技能列表
var skills: Array = []

# Owner (玩家)
var player: Node2D

func _ready():
	pass

# 基础攻击
func basic_attack(direction: Vector2) -> void:
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_attack_time < attack_cooldown:
		return
	
	last_attack_time = now
	_perform_attack(direction)

# 可重写的攻击方法
func _perform_attack(direction: Vector2) -> void:
	print("%s 基础攻击!" % weapon_name)

# 使用技能
func use_skill(skill_index: int, direction: Vector2) -> bool:
	if skill_index < 0 or skill_index >= skills.size():
		return false
	
	var skill = skills[skill_index]
	if skill and skill.has_method("activate"):
		return skill.activate(player, direction)
	return false

# 获取所有技能
func get_skills() -> Array:
	return skills

# 伤害计算
func calculate_damage() -> int:
	return damage

# 升级
func level_up() -> void:
	damage += 1
	print("%s 升级! 伤害: %d" % [weapon_name, damage])
