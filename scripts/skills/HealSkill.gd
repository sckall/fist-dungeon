extends SkillBase

# ============ 治疗技能 ============

class_name HealSkill extends SkillBase

var heal_amount: int = 2

func _init():
	skill_name = "治疗"
	description = "恢复生命值"
	cooldown = 10.0
	mana_cost = 15

func _perform_skill(user: Node2D, target: Vector2) -> void:
	print("治疗!")
	
	if user.has_method("heal"):
		user.heal(heal_amount)
	
	# 治疗特效
	var particles = CPUParticles2D.new()
	particles.amount = 20
	particles.lifetime = 1.0
	particles.position = user.position
	particles.direction = Vector2(0, -1)
	particles.spread = 45
	particles.gravity = Vector2(0, -100)
	particles.color = Color(0.3, 0.9, 0.4)
	
	user.get_parent().add_child(particles)
	
	await user.get_tree().create_timer(1.0).timeout
	particles.queue_free()
