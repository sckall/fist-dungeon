extends Node2D

# ============ 隐藏房间系统 ============

class_name SecretRoom extends Node2D

var is_active: bool = false
var door: Area2D
var room_content: Array = []

signal secret_found

func _ready():
	_create_secret_room()

func _create_secret_room():
	# 创建隐藏入口（假墙）
	var fake_wall = StaticBody2D.new()
	fake_wall.name = "FakeWall"
	fake_wall.position = Vector2(randf_range(50, 750), randf_range(100, 500))
	
	var shape = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(60, 80)
	fake_wall.add_child(shape)
	
	var rect = ColorRect.new()
	rect.size = Vector2(60, 80)
	rect.color = Color(0.2, 0.15, 0.1)
	fake_wall.add_child(rect)
	
	add_child(fake_wall)
	
	# 创建门（可打破）
	door = Area2D.new()
	door.name = "SecretDoor"
	door.position = Vector2(0, -40)
	
	var door_shape = CollisionShape2D.new()
	door_shape.shape = RectangleShape2D.new()
	door_shape.shape.size = Vector2(40, 60)
	door.add_child(door_shape)
	
	var door_rect = ColorRect.new()
	door_rect.size = Vector2(40, 60)
	door_rect.color = Color(0.4, 0.3, 0.2)
	door_rect.name = "DoorRect"
	door.add_child(door_rect)
	
	fake_wall.add_child(door)
	
	# 隐藏房间内容
	_create_treasure()

func _create_treasure():
	# 随机生成宝藏
	var treasure_types = ["gold_chest", "weapon_chest", "heal_fountain"]
	var type = treasure_types.pick_random()
	
	match type:
		"gold_chest":
			_create_gold_chest()
		"weapon_chest":
			_create_weapon_chest()
		"heal_fountain":
			_create_heal_fountain()

func _create_gold_chest():
	var chest = Area2D.new()
	chest.name = "GoldChest"
	chest.position = Vector2(400, 450)
	
	var shape = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(40, 30)
	chest.add_child(shape)
	
	var rect = ColorRect.new()
	rect.size = Vector2(40, 30)
	rect.color = Color(0.8, 0.6, 0.2)
	chest.add_child(rect)
	
	add_child(chest)
	room_content.append(chest)

func _create_weapon_chest():
	var chest = Area2D.new()
	chest.name = "WeaponChest"
	chest.position = Vector2(400, 450)
	
	var shape = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(40, 30)
	chest.add_child(shape)
	
	var rect = ColorRect.new()
	rect.size = Vector2(40, 30)
	rect.color = Color(0.7, 0.3, 0.8)
	chest.add_child(rect)
	
	add_child(chest)
	room_content.append(chest)

func _create_heal_fountain():
	var fountain = Area2D.new()
	fountain.name = "HealFountain"
	fountain.position = Vector2(400, 450)
	
	var shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = 25
	fountain.add_child(shape)
	
	var circle = ColorRect.new()
	circle.size = Vector2(50, 50)
	circle.position = Vector2(-25, -25)
	circle.color = Color(0.3, 0.7, 0.9, 0.5)
	fountain.add_child(circle)
	
	add_child(fountain)
	room_content.append(fountain)

func _on_body_entered(body):
	if body.is_in_group("player"):
		_open_door()

func _open_door():
	if is_active:
		return
	
	is_active = true
	print("发现隐藏房间!")
	secret_found.emit()
	
	# 打开门
	if door and is_instance_valid(door):
		var tween = door.create_tween()
		tween.tween_property(door.get_node("DoorRect"), "color", Color(0.2, 0.2, 0.1), 0.5)
		
		# 移除碰撞
		for child in door.get_children():
			if child is CollisionShape2D:
				child.queue_free()

func _process(delta):
	# 检测玩家交互
	for content in room_content:
		if is_instance_valid(content):
			var player = get_tree().get_first_node_in_group("player")
			if player and player.position.distance_to(content.position) < 40:
				_collect_treasure(content)

func _collect_treasure(content: Node2D):
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	match content.name:
		"GoldChest":
			var gold_amount = 10 + randi() % 20
			if player.has_method("collect_gold"):
				player.collect_gold(gold_amount)
			print("获得金币: %d" % gold_amount)
		
		"WeaponChest":
			if player.weapon and player.weapon.has_method("level_up"):
				player.weapon.level_up()
			print("武器升级!")
		
		"HealFountain":
			if player.has_method("heal"):
				player.heal(3)
			print("生命恢复!")
	
	room_content.erase(content)
	content.queue_free()
