extends SkillBase

# ============ 隐身技能 ============

class_name InvisibilitySkill extends SkillBase

var invis_duration: float = 3.0

func _init():
	skill_name = "隐身"
	description = "短暂隐身，无敌且敌人不会追踪"
	cooldown = 8.0
	mana_cost = 20

func _perform_skill(user: Node2D, target: Vector2) -> void:
	print("隐身!")
	
	# 效果
	var tween = user.create_tween()
	tween.tween_property(user, "modulate:a", 0.3, 0.3)
	
	# 无敌
	if user.has_method("set_invincible"):
		user.set_invincible(true)
	
	# 敌人忽略
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if e.has_method("set_target"):
			e.set_target(null)
	
	# 恢复
	await user.get_tree().create_timer(invis_duration).timeout
	
	tween = user.create_tween()
	tween.tween_property(user, "modulate:a", 1.0, 0.3)
	
	if user.has_method("set_invincible"):
		user.set_invincible(false)
