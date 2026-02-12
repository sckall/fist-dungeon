extends WeaponSystem

# ============ 拳法系统 ============
# 技能：冲刺拳、旋风腿、蓄力重击

class_name FistSystem extends WeaponSystem

# 技能实例
var dash_punch: SkillBase
var spin_kick: SkillBase
var charge_punch: SkillBase

# 蓄力状态
var is_charging: bool = false
var charge_time: float = 0.0
var max_charge_time: float = 1.0
var charge_level: int = 0

func _init():
	weapon_name = "拳法"
	damage = 2
	attack_range = 40.0
	attack_cooldown = 0.3
	
	# 初始化技能
	dash_punch = DashPunchSkill.new()
	dash_punch.skill_name = "冲刺拳"
	dash_punch.description = "快速冲刺并攻击"
	dash_punch.cooldown = 2.0
	
	# 这里简化：旋风腿作为基础攻击的强化
	# 蓄力重击通过特殊输入触发
	
	skills = [dash_punch]

# 基础攻击 - 冲刺拳
func _perform_attack(direction: Vector2) -> void:
	if direction.length() > 0:
		# 冲刺效果
		var jump_height = 200.0
		player.velocity.y = -jump_height
		player.velocity.x = direction.x * 400.0
		
		# 攻击判定
		_create_hitbox(direction * 60, 30, 3)
		
		print("冲刺拳!")
	else:
		# 普通拳击
		_create_hitbox(Vector2(40, 0), 20, 2)
		print("拳击!")

# 旋风腿 - 按住攻击键
func spin_kill() -> void:
	_create_hitbox(Vector2.ZERO, 80, damage, 0.5)
	print("旋风腿!")
	_create_visual_effect(Color(1, 0.5, 0), 80)

# 蓄力重击 - 按住攻击键蓄力
func start_charge() -> void:
	is_charging = true
	charge_time = 0.0
	charge_level = 0
	print("蓄力中...")

func update_charge(delta: float) -> int:
	if is_charging:
		charge_time += delta
		if charge_time >= max_charge_time:
			charge_time = max_charge_time
			charge_level = 2
		elif charge_time >= max_charge_time * 0.5:
			charge_level = 1
	return charge_level

func release_charge(direction: Vector2) -> void:
	if not is_charging:
		return
	
	var damage_mult = 1.0 + charge_level * 1.5
	_create_hitbox(direction * 80, 60, int(damage * damage_mult), 0.8)
	
	var color = Color.YELLOW if charge_level == 1 else Color.RED
	_create_visual_effect(color, 60)
	
	print("蓄力重击! 等级:%d 伤害:%d" % [charge_level, int(damage * damage_mult)])
	
	is_charging = false
	charge_time = 0.0
	charge_level = 0

# 创建攻击判定
func _create_hitbox(offset: Vector2, size: float, dmg: int, knockback: float = 0.3):
	var area = Area2D.new()
	area.position = player.position + offset
	
	var shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = size
	area.add_child(shape)
	
	# 设置碰撞层
	area.collision_layer = 0
	area.collision_mask = 2  # 攻击敌人层
	
	# 伤害数据
	area.set_meta("damage", dmg)
	area.set_meta("knockback", knockback)
	area.set_meta("attacker", "player")
	
	# 定时移除
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(area.queue_free)
	
	player.get_parent().add_child(area)

# 创建视觉效果
func _create_visual_effect(color: Color, size: float):
	var rect = ColorRect.new()
	rect.size = Vector2(size, size)
	rect.position = -size / 2
	rect.color = color
	rect.modulate.a = 0.5
	
	var tween = player.get_tree().create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, 0.3)
	tween.tween_callback(rect.queue_free)
	
	player.get_parent().add_child(rect)

# 升级
func level_up() -> void:
	damage += 1
	attack_cooldown = max(0.1, attack_cooldown - 0.02)
	print("拳法升级! 伤害:%d 攻速:%.2f" % [damage, attack_cooldown])


# ============ 技能基类 ============
class_name SkillBase

var skill_name: String = "技能"
var description: String = ""
var cooldown: float = 1.0
var last_use_time: float = -10.0
var level: int = 1

func _init():
	pass

func can_use() -> bool:
	var now = Time.get_ticks_msec() / 1000.0
	return now - last_use_time >= cooldown

func activate(user: Node2D, direction: Vector2) -> bool:
	if not can_use():
		return false
	
	last_use_time = Time.get_ticks_msec() / 1000.0
	_perform_skill(user, direction)
	return true

func _perform_skill(user: Node2D, direction: Vector2) -> void:
	print("%s 技能释放!" % skill_name)


# ============ 冲刺拳技能 ============
class_name DashPunchSkill extends SkillBase

var dash_distance: float = 150.0
var dash_speed: float = 600.0

func _init():
	skill_name = "冲刺拳"
	description = "快速冲刺并攻击敌人"
	cooldown = 2.0

func _perform_skill(user: Node2D, direction: Vector2) -> void:
	if direction.length() == 0:
		direction = Vector2(1, 0)
	
	# 冲刺位移
	user.velocity = direction * dash_speed
	user.velocity.y = -100  # 稍微向上
	
	print("冲刺拳!")
