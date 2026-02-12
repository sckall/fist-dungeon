extends Node2D

# ============ 玩家 ============
class_name Player extends CharacterBody2D

signal died

var speed: float = 300.0
var jump_force: float = -450.0
var gravity: float = 980.0
var hp: int = 5
var max_hp: int = 5
var is_alive: bool = true

func _ready():
	add_to_group("player")

func _physics_process(delta):
	if not is_alive: return
	
	velocity.y += gravity * delta
	velocity.x = Input.get_axis("ui_left", "ui_right") * speed
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force
	
	move_and_slide()
	
	# 掉落死亡
	if position.y > 650:
		die()

func die():
	is_alive = false
	hp = max_hp
	position = Vector2(100, 500)
	is_alive = true
	died.emit()

func take_damage():
	hp -= 1
	if hp <= 0:
		die()
