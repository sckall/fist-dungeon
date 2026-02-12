extends EnemySystem

# ============ 蜘蛛 ============

class_name Spider extends EnemySystem

var web_shot_cooldown: float = 0.0
var is_climbing: bool = false

func _init():
	enemy_name = "蜘蛛"
	hp = 2
	max_hp = 2
	speed = 70.0
	damage = 1
	attack_cooldown = 3.0

func _setup_appearance():
	# 身体
	var body = ColorRect.new()
	body.size = Vector2(24, 20)
	body.position = Vector2(-12, -10)
	body.color = Color(0.2, 0.2, 0.25)
	add_child(body)
	
	# 头
	var head = ColorRect.new()
	head.size = Vector2(16, 14)
	head.position = Vector2(-8, -22)
	head.color = Color(0.25, 0.25, 0.3)
	add_child(head)
	
	# 眼睛（8只）
	for i in range(4):
		var eye_l = ColorRect.new()
		eye_l.size = Vector2(3, 3)
		eye_l.position = Vector2(-10 + i * 5, -20)
		eye_l.color = Color(0.8, 0.1, 0.1)
		add_child(eye_l)
	
	# 腿（8条）
	for i in range(4):
		var leg_l = Line2D.new()
		leg_l.points = [Vector2(-8, 0), Vector2(-20 - i * 5, -10 + i * 8)]
		leg_l.width = 2
		leg_l.default_color = Color(0.2, 0.2, 0.25)
		add_child(leg_l)
		
		var leg_r = Line2D.new()
		leg_r.points = [Vector2(8, 0), Vector2(20 + i * 5, -10 + i * 8)]
		leg_r.width = 2
		leg_r.default_color = Color(0.2, 0.2, 0.25)
		add_child(leg_r)
	
	# 碰撞
	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = 15
	area.add_child(shape)
	add_child(area)

func _physics_process(delta):
	if not is_alive:
		return
	
	# 蜘蛛AI - 会吐丝和爬墙
	web_shot_cooldown -= delta
	
	match state:
		State.IDLE:
			_find_target()
			if target:
				state = State.CHASE
		State.CHASE:
			if is_instance_valid(target):
				var direction = (target.position - position).normalized()
				
				# 随机跳跃
				if randf() < 0.01 and not is_climbing:
					_web_jump(direction)
				else:
					position += direction * speed * delta
				
				# 吐丝攻击
				if web_shot_cooldown <= 0 and position.distance_to(target.position) > 100:
					_shoot_web(target)
					web_shot_cooldown = attack_cooldown
				
				if position.distance_to(target.position) < attack_range:
					state = State.ATTACK
		State.ATTACK:
			var now = Time.get_ticks_msec() / 1000.0
			if now - last_attack_time >= attack_cooldown:
				_attack_target()
				last_attack_time = now
			if not is_instance_valid(target) or position.distance_to(target.position) > attack_range:
				state = State.CHASE

func _web_jump(direction: Vector2):
	is_climbing = true
	var jump_force = -250.0
	velocity = direction * 150 + Vector2(0, jump_force)
	
	var tween = create_tween()
	tween.tween_interval(0.4)
	tween.tween_callback(func(): is_climbing = false)

func _shoot_web(target: Node2D):
	if not is_instance_valid(target):
		return
	
	# 创建蛛丝
	var web = Line2D.new()
	web.points = [position, target.position]
	web.width = 3
	web.default_color = Color(0.9, 0.9, 0.9, 0.7)
	
	get_parent().add_child(web)
	
	# 减速效果
	if target.has_method("apply_status"):
		target.apply_status("slow", 2.0)
	
	var tween = web.create_tween()
	tween.tween_property(web, "modulate:a", 0.0, 1.0)
	tween.tween_callback(web.queue_free)
	
	print("蜘蛛吐丝!")

func _attack_target():
	if target and is_instance_valid(target):
		if target.has_method("take_damage"):
			target.take_damage()
		print("蜘蛛攻击!")
