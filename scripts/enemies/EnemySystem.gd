extends Node2D

# ============ 敌人系统基类 ============

class_name EnemySystem extends Node2D

var enemy_name: String = "敌人"
var hp: int = 1
var max_hp: int = 1
var speed: float = 50.0
var damage: int = 1
var attack_range: float = 30.0
var attack_cooldown: float = 1.0
var last_attack_time: float = 0.0

var target: Node2D = null
var is_alive: bool = true
var is_hurt: bool = false
var hurt_timer: float = 0.0

# 状态
enum State { IDLE, CHASE, ATTACK, HURT, DEAD }
var state: int = State.IDLE

func _ready():
	add_to_group("enemies")
	_setup_appearance()

func _physics_process(delta):
	if not is_alive:
		return
	
	match state:
		State.IDLE:
			_update_idle(delta)
		State.CHASE:
			_update_chase(delta)
		State.ATTACK:
			_update_attack(delta)
		State.HURT:
			_update_hurt(delta)
	
	# 受伤恢复
	if is_hurt:
		hurt_timer -= delta
		if hurt_timer <= 0:
			is_hurt = false
			state = State.IDLE

func _setup_appearance():
	# 子类重写
	pass

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if not is_alive:
		return
	
	hp -= amount
	is_hurt = true
	hurt_timer = 0.2
	
	position += knockback * 0.1
	
	flash_damage()
	
	if hp <= 0:
		die()
	else:
		state = State.HURT
	
	print("%s 受伤! HP:%d/%d" % [enemy_name, hp, max_hp])

func flash_damage():
	# 受伤闪烁效果
	pass

func die():
	is_alive = false
	state = State.DEAD
	print("%s 死亡!" % enemy_name)
	
	# 消失动画
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)

func _update_idle(delta):
	_find_target()
	if target:
		state = State.CHASE

func _update_chase(delta):
	if not is_instance_valid(target):
		state = State.IDLE
		return
	
	var direction = (target.position - position).normalized()
	position += direction * speed * delta
	
	if position.distance_to(target.position) < attack_range:
		state = State.ATTACK

func _update_attack(delta):
	if not is_instance_valid(target):
		state = State.IDLE
		return
	
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_attack_time >= attack_cooldown:
		_attack_target()
		last_attack_time = now
	
	if position.distance_to(target.position) > attack_range:
		state = State.CHASE

func _update_hurt(delta):
	pass

func _find_target():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		target = player

func _attack_target():
	if target and is_instance_valid(target):
		print("%s 攻击!" % enemy_name)

func get_damage() -> int:
	return damage
