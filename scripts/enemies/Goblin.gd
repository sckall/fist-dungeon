extends EnemySystem

# ============ 哥布林 ============

class_name Goblin extends EnemySystem

var is_dodging: bool = false
var dodge_cooldown: float = 0.0

func _init():
	enemy_name = "哥布林"
	hp = 4
	max_hp = 4
	speed = 60.0
	damage = 2
	attack_cooldown = 1.5
	attack_range = 35.0

func _setup_appearance():
	# 身体
	var body = ColorRect.new()
	body.size = Vector2(28, 36)
	body.position = Vector2(-14, -36)
	body.color = Color(0.4, 0.5, 0.3)
	add_child(body)
	
	# 耳朵
	var ear_l = ColorRect.new()
	ear_l.size = Vector2(8, 12)
	ear_l.position = Vector2(-20, -32)
	ear_l.color = Color(0.3, 0.4, 0.2)
	add_child(ear_l)
	
	var ear_r = ColorRect.new()
	ear_r.size = Vector2(8, 12)
	ear_r.position = Vector2(12, -32)
	ear_r.color = Color(0.3, 0.4, 0.2)
	add_child(ear_r)
	
	# 眼睛
	var eye_l = ColorRect.new()
	eye_l.size = Vector2(6, 6)
	eye_l.position = Vector2(-10, -28)
	eye_l.color = Color(1.0, 0.3, 0.3)
	add_child(eye_l)
	
	var eye_r = ColorRect.new()
	eye_r.size = Vector2(6, 6)
	eye_r.position = Vector2(4, -28)
	eye_r.color = Color(1.0, 0.3, 0.3)
	add_child(eye_r)
	
	# 碰撞
	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	shape.shape = CapsuleShape2D.new()
	shape.shape.radius = 14
	shape.shape.height = 36
	area.add_child(shape)
	add_child(area)

func _physics_process(delta):
	if not is_alive:
		return
	
	# 闪避冷却
	dodge_cooldown -= delta
	if dodge_cooldown <= 0:
		is_dodging = false
	
	# 哥布林AI - 会闪避
	match state:
		State.IDLE:
			_find_target()
			if target:
				state = State.CHASE
		State.CHASE:
			if is_instance_valid(target):
				var direction = (target.position - position).normalized()
				
				# 检测玩家攻击，准备闪避
				if target.has_meta("is_attacking") and target.get_meta("is_attacking") and not is_dodging and dodge_cooldown <= 0:
					_dodge()
				else:
					position += direction * speed * delta
				
				if position.distance_to(target.position) < attack_range:
					state = State.ATTACK
		State.ATTACK:
			var now = Time.get_ticks_msec() / 1000.0
			if now - last_attack_time >= attack_cooldown:
				_attack_target()
				last_attack_time = now
			if not is_instance_valid(target) or position.distance_to(target.position) > attack_range:
				state = State.CHASE

func _dodge():
	is_dodging = true
	dodge_cooldown = 3.0
	
	# 向后闪避
	var jump_force = -150.0
	velocity = Vector2(-100, jump_force)
	
	var tween = create_tween()
	tween.tween_interval(0.3)
	tween.tween_callback(func(): is_dodging = false)
	
	print("哥布林闪避!")

func _attack_target():
	if target and is_instance_valid(target):
		if target.has_method("take_damage"):
			target.take_damage()
		print("哥布林攻击!")
