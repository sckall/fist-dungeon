extends SkillBase

# ============ 地刺技能 ============

class_name SpikeSkill extends SkillBase

var spike_count: int = 5
var spike_radius: float = 100.0

func _init():
	skill_name = "地刺"
	description = "在周围升起地刺"
	cooldown = 4.0
	mana_cost = 15

func _perform_skill(user: Node2D, target: Vector2) -> void:
	var center = user.position
	
	for i in range(spike_count):
		var angle = (TAU / spike_count) * i
		var pos = center + Vector2(cos(angle), sin(angle)) * spike_radius
		
		# 创建地刺
		var spike = Line2D.new()
		spike.points = [pos, pos + Vector2(0, -40)]
		spike.width = 6
		spike.default_color = Color(0.6, 0.3, 0.2)
		
		user.get_parent().add_child(spike)
		
		# 攻击判定
		var area = Area2D.new()
		area.position = pos + Vector2(0, -20)
		
		var shape = CollisionShape2D.new()
		shape.shape = RectangleShape2D.new()
		shape.shape.size = Vector2(20, 40)
		area.add_child(shape)
		
		area.set_meta("damage", 4)
		area.set_meta("attacker", "player")
		area.set_meta("is_spike", true)
		
		user.get_parent().add_child(area)
		
		# 定时移除
		var timer = spike.create_tween()
		timer.tween_interval(0.3)
		tween().tween_property(spike, "modulate:a", 0.0, 0.3)
		timer.tween_callback(spike.queue_free)
		timer.tween_callback(area.queue_free)
	
	print("地刺!")
