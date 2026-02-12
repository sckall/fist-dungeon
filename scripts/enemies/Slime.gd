extends EnemySystem

# ============ 史莱姆 ============

class_name Slime extends EnemySystem

var jump_timer: float = 0.0
var is_jumping: bool = false

func _init():
	enemy_name = "史莱姆"
	hp = 3
	max_hp = 3
	speed = 30.0
	damage = 1
	attack_cooldown = 3.0
	attack_range = 40.0

func _setup_appearance():
	# 身体（半圆形）
	var body = ColorRect.new()
	body.size = Vector2(32, 24)
	body.position = Vector2(-16, -24)
	body.color = Color(0.3, 0.7, 0.3)
	add_child(body)
	
	# 眼睛
	var eye_l = ColorRect.new()
	eye_l.size = Vector2(6, 6)
	eye_l.position = Vector2(-10, -20)
	eye_l.color = Color.WHITE
	add_child(eye_l)
	
	var eye_r = ColorRect.new()
	eye_r.size = Vector2(6, 6)
	eye_r.position = Vector2(4, -20)
	eye_r.color = Color.WHITE
	add_child(eye_r)
	
	# 碰撞
	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	shape.shape = CapsuleShape2D.new()
	shape.shape.radius = 16
	shape.shape.height = 32
	area.add_child(shape)
	add_child(area)

func _physics_process(delta):
	if not is_alive:
		return
	
	# 史莱姆跳跃AI
	jump_timer -= delta
	if jump_timer <= 0 and not is_jumping:
		_jump()
	
	match state:
		State.IDLE:
			_find_target()
			if target:
				state = State.CHASE
		State.CHASE:
			if is_instance_valid(target):
				if not is_jumping:
					var direction = (target.position - position).normalized()
					position += direction * speed * 0.5 * delta
				
				if position.distance_to(target.position) < attack_range:
					state = State.ATTACK
		State.ATTACK:
			var now = Time.get_ticks_msec() / 1000.0
			if now - last_attack_time >= attack_cooldown:
				_attack_target()
				last_attack_time = now

func _jump():
	is_jumping = true
	var jump_force = -200.0
	var jump_dir = Vector2.ZERO
	
	if is_instance_valid(target):
		jump_dir = (target.position - position).normalized()
	else:
		jump_dir = Vector2(randf_range(-1, 1), -1).normalized()
	
	velocity = jump_dir * 100 + Vector2(0, jump_force)
	jump_timer = 2.0 + randf()
	
	# 落地检测
	var tween = create_tween()
	tween.tween_interval(0.4)
	tween.tween_callback(func(): is_jumping = false)

func _attack_target():
	if target and is_instance_valid(target):
		if target.has_method("take_damage"):
			target.take_damage()
		print("史莱姆攻击!")
