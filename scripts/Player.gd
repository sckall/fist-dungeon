extends CharacterBody2D

# ============ 玩家 ============

signal died
signal health_changed(current, max)

var hp := 4
var max_hp := 4

var max_speed := 190.0
var acceleration := 1050.0
var deceleration := 1200.0
var jump_force := -370.0
var gravity := 980.0
var fall_gravity_scale := 1.28

var coyote_time := 0.10
var coyote_timer := 0.0
var jump_buffer_time := 0.12
var jump_buffer_timer := 0.0

var invincible := false
var invincible_timer := 0.0

var attack_cooldown := 0.22
var attack_timer := 0.0
var attack_range := 42.0
var facing := 1

func _ready() -> void:
	add_to_group("player")
	_setup_body()

func _setup_body() -> void:
	var collision := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(20, 28)
	collision.shape = rect
	add_child(collision)

	var body := Node2D.new()
	body.name = "Body"
	add_child(body)

	# 身体颜色块
	var cloak := ColorRect.new()
	cloak.name = "Cloak"
	cloak.size = Vector2(16, 18)
	cloak.position = Vector2(-8, -8)
	cloak.color = Color(0.12, 0.28, 0.56)
	body.add_child(cloak)

	var torso := ColorRect.new()
	torso.name = "Torso"
	torso.size = Vector2(14, 14)
	torso.position = Vector2(-7, -12)
	torso.color = Color(0.22, 0.75, 0.95)
	body.add_child(torso)

	var head := ColorRect.new()
	head.name = "Head"
	head.size = Vector2(12, 10)
	head.position = Vector2(-6, -20)
	head.color = Color(0.82, 0.89, 0.98)
	body.add_child(head)

	var visor := ColorRect.new()
	visor.name = "Visor"
	visor.size = Vector2(8, 3)
	visor.position = Vector2(-4, -16)
	visor.color = Color(1.0, 0.97, 0.78)
	body.add_child(visor)

	var blade := ColorRect.new()
	blade.name = "Blade"
	blade.size = Vector2(3, 12)
	blade.position = Vector2(8, -8)
	blade.color = Color(0.90, 0.92, 1.0)
	body.add_child(blade)

func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_apply_movement(delta)
	
	if position.y > 650:
		die()

func _update_timers(delta: float) -> void:
	if attack_timer > 0.0:
		attack_timer -= delta
	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= delta

	if is_on_floor():
		coyote_timer = coyote_time
	elif coyote_timer > 0.0:
		coyote_timer -= delta

	if invincible:
		invincible_timer -= delta
		if invincible_timer <= 0:
			invincible = false

func _apply_movement(delta: float) -> void:
	# 水平
	var axis := Input.get_axis("ui_left", "ui_right")
	if axis > 0.01:
		facing = 1
	elif axis < -0.01:
		facing = -1

	var target_speed := axis * max_speed
	var rate := acceleration if absf(target_speed) > 0.01 else deceleration
	velocity.x = move_toward(velocity.x, target_speed, rate * delta)

	# 垂直
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time

	var current_gravity := gravity * (fall_gravity_scale if velocity.y > 0.0 else 1.0)
	velocity.y += current_gravity * delta

	# 跳跃释放
	if Input.is_action_just_released("ui_accept") and velocity.y < -120.0:
		velocity.y *= 0.58

	# 跳跃
	if jump_buffer_timer > 0.0 and (coyote_timer > 0.0 or is_on_floor()):
		velocity.y = jump_force
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	move_and_slide()
	_update_visuals()

func _update_visuals() -> void:
	if not has_node("Body"):
		return

	var body = $Body
	body.scale.x = float(facing)

	# 行走动画
	var move_t := Time.get_ticks_msec() / 120.0
	var speed_ratio := clamp(absf(velocity.x) / max_speed, 0.0, 1.0)
	body.position.y = sin(move_t) * 0.8 * speed_ratio

	# 无敌闪烁
	if invincible:
		body.modulate.a = 0.45 if int(Time.get_ticks_msec() / 70) % 2 == 0 else 1.0
	else:
		body.modulate.a = 1.0

func take_damage(amount := 1) -> void:
	if invincible:
		return

	hp -= amount
	invincible = true
	invincible_timer = 0.75
	health_changed.emit(hp, max_hp)

	if hp <= 0:
		die()

func die() -> void:
	hp = max_hp
	invincible = true
	invincible_timer = 1.8
	health_changed.emit(hp, max_hp)
	position = Vector2(100, 500)
	died.emit()

func heal(amount: int) -> void:
	hp = min(max_hp, hp + amount)
	health_changed.emit(hp, max_hp)

func try_attack() -> bool:
	if attack_timer > 0.0:
		return false
	attack_timer = attack_cooldown
	return true
