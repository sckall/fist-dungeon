extends EnemySystem

# ============ 蝙蝠 ============

class_name Bat extends EnemySystem

func _init():
	enemy_name = "蝙蝠"
	hp = 1
	max_hp = 1
	speed = 80.0
	damage = 1
	attack_cooldown = 2.0

func _setup_appearance():
	# 身体
	var body = ColorRect.new()
	body.size = Vector2(24, 16)
	body.position = Vector2(-12, -8)
	body.color = Color(0.4, 0.3, 0.5)
	add_child(body)
	
	# 翅膀
	var wing_l = ColorRect.new()
	wing_l.size = Vector2(12, 8)
	wing_l.position = Vector2(-18, -4)
	wing_l.color = Color(0.5, 0.4, 0.6)
	add_child(wing_l)
	
	var wing_r = ColorRect.new()
	wing_r.size = Vector2(12, 8)
	wing_r.position = Vector2(6, -4)
	wing_r.color = Color(0.5, 0.4, 0.6)
	add_child(wing_r)
	
	# 碰撞
	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = 12
	area.add_child(shape)
	add_child(area)

func _physics_process(delta):
	if not is_alive:
		return
	
	# 飞行上下浮动
	position.y += sin(Time.get_ticks_msec() / 200.0) * 0.5
	
	# 蝙蝠飞行AI
	match state:
		State.IDLE:
			_find_target()
			if target:
				state = State.CHASE
		State.CHASE:
			if is_instance_valid(target):
				var direction = (target.position - position).normalized()
				position += direction * speed * delta
				
				if position.distance_to(target.position) < attack_range:
					state = State.ATTACK
		State.ATTACK:
			var now = Time.get_ticks_msec() / 1000.0
			if now - last_attack_time >= attack_cooldown:
				_attack_target()
				last_attack_time = now
			if not is_instance_valid(target) or position.distance_to(target.position) > attack_range + 50:
				state = State.CHASE

func _attack_target():
	if target and is_instance_valid(target):
		if target.has_method("take_damage"):
			target.take_damage()
		print("蝙蝠攻击!")
