extends WeaponSystem

# ============ 棍法系统 ============
# 技能：旋风棍、突刺、下劈

class_name StaffWeapon extends WeaponSystem

# 技能实例
var spin_staff: SkillBase
var thrust: SkillBase
var slash: SkillBase

func _init():
	weapon_name = "棍法"
	damage = 3
	attack_range = 80.0
	attack_cooldown = 0.5
	
	# 初始化技能
	skills = []

# 基础攻击 - 棍击
func _perform_attack(direction: Vector2) -> void:
	_create_hitbox(direction * 50, 40, damage)
	_create_sweep_effect(direction)
	print("棍击!")

# 旋风棍 - 按住攻击
func spin_staff_attack() -> void:
	_create_hitbox(Vector2.ZERO, 100, int(damage * 1.5), 0.5)
	_create_spin_effect()
	print("旋风棍!")

# 突刺 - 快速位移攻击
func thrust_attack(direction: Vector2) -> void:
	if direction.length() == 0:
		direction = Vector2(1, 0)
	
	# 位移
	var jump_force = -200.0
	player.velocity = direction * 300 + Vector2(0, jump_force)
	
	# 攻击判定
	_create_hitbox(direction * 80, 50, int(damage * 2))
	_create_thrust_effect(direction)
	print("突刺!")

# 下劈 - 空中攻击
func slash_attack() -> void:
	player.velocity.y = 300  # 快速下落
	_create_hitbox(Vector2(0, 40), 80, int(damage * 1.5), 0.8)
	_create_slash_effect()
	print("下劈!")

# 创建攻击判定
func _create_hitbox(offset: Vector2, size: float, dmg: int, knockback: float = 0.3):
	var area = Area2D.new()
	area.position = player.position + offset
	
	var shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = size
	area.add_child(shape)
	
	area.set_meta("damage", dmg)
	area.set_meta("knockback", knockback)
	area.set_meta("attacker", "player")
	
	var timer = player.get_tree().create_timer(0.15)
	timer.timeout.connect(area.queue_free)
	
	player.get_parent().add_child(area)

# 视觉效果
func _create_sweep_effect(direction: Vector2):
	var arc = Line2D.new()
	arc.points = []
	for i in range(12):
		var angle = PI * i / 12
		arc.points.append(Vector2(cos(angle) * 30, sin(angle) * 30))
	arc.width = 4
	arc.default_color = Color(0.6, 0.4, 0.2)
	arc.position = player.position
	
	var tween = player.create_tween()
	tween.tween_property(arc, "modulate:a", 0.0, 0.2)
	tween.tween_callback(arc.queue_free)
	
	player.get_parent().add_child(arc)

func _create_spin_effect():
	var circle = Line2D.new()
	circle.points = []
	for i in range(20):
		var angle = TAU * i / 20
		circle.points.append(Vector2(cos(angle) * 80, sin(angle) * 80))
	circle.width = 8
	circle.default_color = Color(0.6, 0.4, 0.2, 0.5)
	circle.position = player.position
	
	var tween = circle.create_tween().set_loops(2)
	tween.tween_property(circle, "rotation", TAU, 0.3)
	tween.tween_property(circle, "modulate:a", 0.0, 0.1)
	tween.tween_callback(circle.queue_free)
	
	player.get_parent().add_child(circle)

func _create_thrust_effect(direction: Vector2):
	var line = Line2D.new()
	line.points = [player.position, player.position + direction * 100]
	line.width = 12
	line.default_color = Color(0.8, 0.6, 0.3)
	
	var tween = player.create_tween()
	tween.tween_property(line, "width", 0.0, 0.2)
	tween.tween_callback(line.queue_free)
	
	player.get_parent().add_child(line)

func _create_slash_effect():
	var slash = Line2D.new()
	slash.points = [Vector2(-60, -20), Vector2(60, 40)]
	slash.width = 16
	slash.default_color = Color(0.7, 0.5, 0.25, 0.5)
	slash.position = player.position
	
	var tween = slash.create_tween()
	tween.tween_property(slash, "modulate:a", 0.0, 0.2)
	tween.tween_callback(slash.queue_free)
	
	player.get_parent().add_child(slash)

# 升级
func level_up() -> void:
	damage += 1
	attack_cooldown = max(0.15, attack_cooldown - 0.02)
	print("棍法升级! 伤害:%d 攻速:%.2f" % [damage, attack_cooldown])
