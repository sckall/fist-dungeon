extends SkillBase

# ============ 光束技能 ============

class_name BeamSkill extends SkillBase

var beam_length: float = 300.0

func _init():
	skill_name = "光束"
	description = "发射远程光束"
	cooldown = 3.0
	mana_cost = 10

func _perform_skill(user: Node2D, target: Vector2) -> void:
	var direction = (target - user.position).normalized()
	if direction.length() == 0:
		direction = Vector2(1, 0)
	
	# 创建光束
	var beam = Line2D.new()
	beam.points = [user.position, user.position + direction * beam_length]
	beam.width = 8
	beam.default_color = Color(0.3, 0.5, 1.0)
	beam.modulate.a = 0.8
	
	user.get_parent().add_child(beam)
	
	# 攻击判定
	var area = Area2D.new()
	area.position = user.position + direction * (beam_length / 2)
	
	var shape = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(beam_length, 20)
	area.add_child(shape)
	
	area.set_meta("damage", 3)
	area.set_meta("attacker", "player")
	
	user.get_parent().add_child(area)
	
	# 定时移除
	var timer = beam.create_tween()
	timer.tween_property(beam, "modulate:a", 0.0, 0.5)
	timer.parallel().tween_property(beam, "width", 0.0, 0.5)
	timer.tween_callback(beam.queue_free)
	timer.tween_callback(area.queue_free)
	
	print("光束!")
