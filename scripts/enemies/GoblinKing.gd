extends EnemySystem

# ============ 哥布林王 (Boss) ============

class_name GoblinKing extends EnemySystem

# 多阶段
var phase: int = 1
var max_phase: int = 3
var attack_pattern: int = 0

# 召唤
var summon_timer: float = 0.0
var summon_interval: float = 5.0
var minions_spawned: int = 0
var max_minions: int = 3

# 特殊攻击
var special_attack_timer: float = 0.0
var is_teleporting: bool = false

func _init():
	enemy_name = "哥布林王"
	hp = 30
	max_hp = 30
	speed = 40.0
	damage = 3
	attack_cooldown = 2.0
	attack_range = 50.0

func _setup_appearance():
	# 王冠
	var crown = ColorRect.new()
	crown.size = Vector2(24, 12)
	crown.position = Vector2(-12, -62)
	crown.color = Color(1.0, 0.8, 0.2)
	add_child(crown)
	
	# 更大的身体
	var body = ColorRect.new()
	body.size = Vector2(40, 48)
	body.position = Vector2(-20, -48)
	body.color = Color(0.5, 0.3, 0.2)
	add_child(body)
	
	# 眼睛（红色）
	var eye_l = ColorRect.new()
	eye_l.size = Vector2(10, 10)
	eye_l.position = Vector2(-16, -38)
	eye_l.color = Color(1.0, 0.0, 0.0)
	add_child(eye_l)
	
	var eye_r = ColorRect.new()
	eye_r.size = Vector2(10, 10)
	eye_r.position = Vector2(6, -38)
	eye_r.color = Color(1.0, 0.0, 0.0)
	add_child(eye_r)
	
	# 权杖
	var staff = ColorRect.new()
	staff.size = Vector2(6, 50)
	staff.position = Vector2(22, -40)
	staff.color = Color(0.6, 0.4, 0.2)
	add_child(staff)
	
	var staff_top = ColorRect.new()
	staff_top.size = Vector2(14, 14)
	staff_top.position = Vector2(18, -54)
	staff_top.color = Color(0.3, 0.8, 0.3)
	add_child(staff_top)
	
	# 碰撞
	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	shape.shape = CapsuleShape2D.new()
	shape.shape.radius = 24
	shape.height = 64
	area.add_child(shape)
	add_child(area)

func _physics_process(delta):
	if not is_alive:
		return
	
	summon_timer -= delta
	special_attack_timer -= delta
	
	match state:
		State.IDLE:
			_find_target()
			if target:
				state = State.CHASE
		State.CHASE:
			if is_instance_valid(target):
				var direction = (target.position - position).normalized()
				
				# 阶段变化
				var hp_percent = float(hp) / float(max_hp)
				if hp_percent < 0.33 and phase < 3:
					_change_phase(3)
				elif hp_percent < 0.66 and phase < 2:
					_change_phase(2)
				
				# 召唤小怪
				if summon_timer <= 0 and minions_spawned < max_minions:
					_summon_minion()
					summon_timer = summon_interval
				
				# 特殊攻击
				if special_attack_timer <= 0:
					_special_attack()
					special_attack_timer = 4.0
				
				# 移动
				position += direction * speed * delta
				
				if position.distance_to(target.position) < attack_range:
					state = State.ATTACK
		State.ATTACK:
			var now = Time.get_ticks_msec() / 1000.0
			if now - last_attack_time >= attack_cooldown:
				_attack_target()
				last_attack_time = now

func _change_phase(new_phase: int):
	phase = new_phase
	max_hp += 10
	hp += 10
	
	speed += 10
	damage += 1
	summon_interval -= 1.0
	
	print("哥布林王进入第%d阶段! HP:%d" % [phase, hp])

func _summon_minion():
	if not is_instance_valid(get_parent()):
		return
	
	var goblin = Goblin.new()
	goblin.position = position + Vector2(randf_range(-100, 100), randf_range(-50, 50))
	goblin.hp = 2
	goblin.max_hp = 2
	
	get_parent().add_child(goblin)
	minions_spawned += 1
	
	print("哥布林王召唤小怪! (已召唤: %d/%d)" % [minions_spawned, max_minions])

func _special_attack():
	if not is_instance_valid(target):
		return
	
	match phase:
		1:
			# 冲击波
			_create_shockwave()
		2:
			# 召唤2个
			if minions_spawned < max_minions:
				_summon_minion()
				_summon_minion()
		3:
			# 快速三连击
			for i in range(3):
				await get_tree().create_timer(0.3).timeout
				if is_instance_valid(target):
					_attack_target()

func _create_shockwave():
	var wave = Line2D.new()
	wave.points = []
	wave.width = 20
	wave.default_color = Color(1.0, 0.3, 0.3, 0.5)
	
	for i in range(20):
		wave.points.append(Vector2(0, 0))
	
	wave.position = position
	get_parent().add_child(wave)
	
	var tween = create_tween()
	tween.tween_method(func(t): 
		for i in range(20):
			wave.points[i] = Vector2(t * i * 2, sin(i * 0.5) * 20)
	, 0.0, 300.0, 1.0)
	tween.tween_callback(wave.queue_free)
	
	print("哥布林王释放冲击波!")

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if not is_alive:
		return
	
	hp -= amount
	is_hurt = true
	hurt_timer = 0.3
	position += knockback * 0.2
	
	if hp <= 0:
		die()
	else:
		state = State.HURT

func _attack_target():
	if target and is_instance_valid(target):
		if target.has_method("take_damage"):
			target.take_damage()
		print("哥布林王攻击!")

func die():
	is_alive = false
	state = State.DEAD
	print("=== 哥布林王被击败! 胜利! ===")
	
	# 胜利特效
	var particles = CPUParticles2D.new()
	particles.amount = 50
	particles.lifetime = 2.0
	particles.explosiveness = 1.0
	particles.direction = Vector2(0, -1)
	particles.spread = 180
	particles.gravity = Vector2(0, 200)
	particles.color = Color(1.0, 0.8, 0.2)
	particles.position = position
	get_parent().add_child(particles)
	
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_callback(func(): 
		get_tree().paused = true
		print("游戏通关!")
	)
	
	queue_free()
