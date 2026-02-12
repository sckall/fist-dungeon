extends CharacterBody2D

# ============ 玩家控制器 ============

signal died
signal health_changed(current, max)
signal gold_changed(amount)
signal level_changed(level)

# 预加载所有类
const WeaponSystemScript = preload("res://scripts/weapons/WeaponSystem.gd")
const FistSystemScript = preload("res://scripts/weapons/FistSystem.gd")
const StaffWeaponScript = preload("res://scripts/weapons/StaffWeapon.gd")
const SkillBaseScript = preload("res://scripts/skills/SkillBase.gd")
const FlightSkillScript = preload("res://scripts/skills/FlightSkill.gd")
const BeamSkillScript = preload("res://scripts/skills/BeamSkill.gd")
const SpikeSkillScript = preload("res://scripts/skills/SpikeSkill.gd")
const InvisibilitySkillScript = preload("res://scripts/skills/InvisibilitySkill.gd")
const HealSkillScript = preload("res://scripts/skills/HealSkill.gd")
const PoisonSkillScript = preload("res://scripts/skills/PoisonSkill.gd")

# 属性
var hp: int = 5
var max_hp: int = 5
var speed: float = 200.0
var jump_force: float = -350.0
var gravity: float = 800.0
var gravity_scale: float = 1.0

# 状态
var is_on_ground: bool = false
var is_invincible: bool = false
var invincible_timer: float = 0.0
var is_attacking: bool = false
var is_charging: bool = false
var facing_right: bool = true

# 蓄力
var charge_time: float = 0.0
var charge_level: int = 0

# 金币
var gold: int = 0

# 武器
var weapon: Node
var weapon_name: String = "拳法"

# 技能
var skill1: Node
var skill2: Node
var skill3: Node
var skills: Array = []

# 存档
var save_system: Node

func _ready():
	add_to_group("player")
	
	# 初始化存档
	save_system = preload("res://scripts/ui/SaveSystem.gd").new()
	add_child(save_system)
	load_progress()
	
	# 初始化武器
	_init_weapon()
	
	# 初始化技能
	_init_skills()
	
	print("玩家初始化完成! HP:%d 金币:%d 关卡:%d" % [hp, gold, save_system.save_data["level"]])

func _init_weapon():
	weapon = FistSystemScript.new()
	add_child(weapon)
	weapon_name = "拳法"

func _init_skills():
	skill1 = FlightSkillScript.new()
	skill2 = BeamSkillScript.new()
	skill3 = SpikeSkillScript.new()
	
	# 额外技能（可在隐藏房间获得）
	if save_system.has_skill("invisibility"):
		skill1 = InvisibilitySkillScript.new()
	if save_system.has_skill("heal"):
		skill2 = HealSkillScript.new()
	if save_system.has_skill("poison"):
		skill3 = PoisonSkillScript.new()
	
	skills = [skill1, skill2, skill3]
	
	# 默认解锁
	save_system.unlock_skill("flight")
	save_system.unlock_skill("beam")
	save_system.unlock_skill("spike")

# 切换武器
func switch_weapon(weapon_type: String):
	if weapon:
		weapon.queue_free()
	
	match weapon_type:
		"fist":
			weapon = FistSystemScript.new()
		"staff":
			weapon = StaffWeaponScript.new()
	
	add_child(weapon)
	weapon_name = "棍法"
	print("切换武器: %s" % weapon_name)

func _physics_process(delta):
	# 重力
	velocity.y += gravity * gravity_scale * delta
	
	# 移动输入
	var input_x = Input.get_axis("ui_left", "ui_right")
	velocity.x = input_x * speed
	
	# 蓄力更新
	if is_charging and weapon and weapon.has_method("update_charge"):
		weapon.update_charge(delta)
	
	# 跳跃
	if Input.is_action_just_pressed("ui_accept") and is_on_ground:
		velocity.y = jump_force
		is_on_ground = false
	
	# 应用移动
	move_and_slide()
	
	# 检测地面
	_detect_ground()
	
	# 无敌计时
	if is_invincible:
		invincible_timer -= delta
		if invincible_timer <= 0:
			is_invincible = false
	
	# 掉落死亡
	if position.y > 700:
		die()

func _detect_ground():
	is_on_ground = false
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_normal().y > 0.5:
			is_on_ground = true
			break

func _unhandled_input(event):
	if event.is_action_pressed("ui_select"):
		_attack_start()
	
	if event.is_action_released("ui_select"):
		_attack_end()
	
	if event.is_action_pressed("ui_up"):
		_use_skill(0)
	
	if event.is_action_pressed("ui_page_up"):
		_use_skill(1)
	
	if event.is_action_pressed("ui_home"):
		_use_skill(2)

func _attack_start():
	is_attacking = true
	is_charging = true
	charge_time = 0.0
	charge_level = 0
	if weapon and weapon.has_method("start_charge"):
		weapon.start_charge()

func _attack_end():
	if is_charging and weapon and weapon.has_method("release_charge"):
		var direction = Vector2(1, 0) if facing_right else Vector2(-1, 0)
		weapon.release_charge(direction)
	
	is_attacking = false
	is_charging = false

func _use_skill(index: int):
	if index >= skills.size():
		return
	
	var skill = skills[index]
	if skill and skill.has_method("activate"):
		var target_pos = get_global_mouse_position()
		skill.activate(self, target_pos)
		print("使用技能: %s" % skill.skill_name if skill.has_method("get_skill_name") else "技能")

func take_damage():
	if is_invincible:
		return
	
	hp -= 1
	is_invincible = true
	invincible_timer = 1.0
	health_changed.emit(hp, max_hp)
	
	# 击退
	velocity = Vector2(-facing_right * 200, -200)
	
	if hp <= 0:
		die()
	else:
		flash_red()

func flash_red():
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)

func die():
	print("=== 玩家死亡! ===")
	
	# 损失金币
	save_system.lose_half_gold()
	save_system.add_death()
	
	# 保存
	save_system.save_game()
	
	# 重生
	hp = max_hp
	position = Vector2(100, 400)
	is_invincible = true
	invincible_timer = 2.0
	
	died.emit()
	
	# 重新加载当前关卡
	get_parent().get_node("Dungeon")._generate_level()
	
	print("已复活! 剩余金币: %d" % save_system.save_data["gold"])

func heal(amount: int):
	hp = min(hp + amount, max_hp)
	health_changed.emit(hp, max_hp)

func collect_gold(amount: int):
	gold += amount
	save_system.add_gold(amount)
	gold_changed.emit(gold)

func collect_item(item: Node2D):
	var type = item.name
	match type:
		"coin":
			collect_gold(1)
		"heart":
			heal(1)
	
	item.queue_free()

func load_progress():
	if save_system:
		hp = max_hp
		gold = save_system.save_data.get("gold", 0)
		level_changed.emit(save_system.save_data["level"])

func save_progress():
	if save_system:
		save_system.save_game()

func get_hp_percent() -> float:
	if max_hp <= 0:
		return 0.0
	return float(hp) / float(max_hp)
