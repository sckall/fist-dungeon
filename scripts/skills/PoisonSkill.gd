extends SkillBase

# ============ 毒药技能 ============

class_name PoisonSkill extends SkillBase

var poison_duration: float = 5.0
var poison_damage: int = 1
var poison_interval: float = 0.5

func _init():
	skill_name = "毒雾"
	description = "释放毒雾，使敌人中毒"
	cooldown = 6.0
	mana_cost = 12

func _perform_skill(user: Node2D, target: Vector2) -> void:
	print("毒雾!")
	
	# 创建毒雾区域
	var area = Area2D.new()
	area.position = user.position
	area.name = "PoisonArea"
	
	var shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = 150
	area.add_child(shape)
	
	# 视觉效果
	var fog = ColorRect.new()
	fog.size = Vector2(300, 300)
	fog.position = Vector2(-150, -150)
	fog.color = Color(0.2, 0.8, 0.2, 0.3)
	area.add_child(fog)
	
	user.get_parent().add_child(area)
	
	# 定时伤害
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if e.has_method("take_damage") and e.position.distance_to(area.position) < 150:
			_apply_poison(e)
	
	# 定时移除
	await user.get_tree().create_timer(poison_duration).timeout
	area.queue_free()

func _apply_poison(enemy: Node2D):
	if not is_instance_valid(enemy):
		return
	
	print("%s 中毒!" % enemy.enemy_name)
	
	# 变色
	var original_color = enemy.modulate
	enemy.modulate = Color(0.3, 0.8, 0.3)
	
	# 定时伤害
	var count = poison_duration / poison_interval
	for i in range(count):
		if is_instance_valid(enemy) and enemy.is_alive:
			await enemy.get_tree().create_timer(poison_interval).timeout
			if enemy.has_method("take_damage"):
				enemy.take_damage(poison_damage, Vector2.ZERO)
	
	# 恢复颜色
	if is_instance_valid(enemy):
		enemy.modulate = original_color
