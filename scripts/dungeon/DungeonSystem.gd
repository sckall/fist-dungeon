extends Node2D
class_name DungeonSystem

# ============ 地牢系统 ============

# 房间管理
var rooms: Array = []
var current_room_index: int = 0
var room_size: Vector2i = Vector2i(800, 600)

# 关卡
var level_num: int = 1
var boss_spawned: bool = false

# 节点
var floor: Node2D
var platforms: Array = []
var enemies: Array = []
var items: Array = []
var exits: Array = []

signal room_changed(room_index: int)
signal level_completed

func _ready():
	_generate_level()

func _generate_level():
	clear_all()
	print("=== 生成地牢 关卡 %d ===" % level_num)
	
	_create_floor()
	_generate_rooms()
	_spawn_enemies()
	_spawn_items()
	_create_exit()

func clear_all():
	for n in [platforms, enemies, items]:
		for obj in n:
			if is_instance_valid(obj):
				obj.queue_free()
		n.clear()
	
	if floor and is_instance_valid(floor):
		floor.queue_free()

func _create_floor():
	floor = StaticBody2D.new()
	floor.position = Vector2(400, 550)
	
	var shape = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(1000, 100)
	shape.position = Vector2(0, 50)
	floor.add_child(shape)
	
	var rect = ColorRect.new()
	rect.size = Vector2(1000, 100)
	rect.position = Vector2(-500, 0)
	rect.color = Color(0.25, 0.2, 0.15)
	floor.add_child(rect)
	
	add_child(floor)
	platforms.append(floor)

func _generate_rooms():
	var platform_count = 5 + level_num * 2
	
	for i in range(platform_count):
		var x = 150 + randi() % 500
		var y = 100 + randi() % 350
		var w = 60 + randi() % 80
		
		_create_platform(x, y, w)

func _create_platform(x, y, w):
	var plat = StaticBody2D.new()
	plat.position = Vector2(x, y)
	
	var shape = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(w, 20)
	plat.add_child(shape)
	
	var rect = ColorRect.new()
	rect.size = Vector2(w, 20)
	rect.color = Color(0.35, 0.45, 0.25)
	plat.add_child(rect)
	
	add_child(plat)
	platforms.append(plat)

func _spawn_enemies():
	var enemy_types = ["bat", "slime", "goblin"]
	var count = 3 + level_num
	
	for i in range(count):
		var plat = platforms.pick_random()
		if plat:
			var type = enemy_types.pick_random()
			var enemy = _create_enemy(type, plat.position.x, plat.position.y - 30)
			if enemy:
				enemies.append(enemy)

func _create_enemy(type: String, x: float, y: float) -> Node2D:
	var enemy: Node2D
	
	# 动态加载敌人脚本
	var script_path = "res://scripts/enemies/" + type.capitalize() + ".gd"
	var script = load(script_path)
	
	if script:
		enemy = script.new()
		enemy.position = Vector2(x, y)
		add_child(enemy)
	
	return enemy

func _spawn_items():
	var count = 2 + level_num / 2
	
	for i in range(count):
		var plat = platforms.pick_random()
		if plat:
			_create_item(plat.position.x, plat.position.y - 40)

func _create_item(x, y):
	var item = Area2D.new()
	item.name = "coin"
	item.position = Vector2(x, y)
	
	var shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = 8
	item.add_child(shape)
	
	var rect = ColorRect.new()
	rect.size = Vector2(12, 12)
	rect.position = Vector2(-6, -6)
	rect.color = Color(1.0, 0.8, 0.2)
	item.add_child(rect)
	
	# 浮动动画
	var tween = item.create_tween().set_loops()
	tween.tween_property(item, "position:y", -5, 0.5).from(0.0)
	
	add_child(item)
	items.append(item)

func _create_exit():
	var exit = Area2D.new()
	exit.name = "Exit"
	exit.position = Vector2(700, 450)
	
	var shape = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(40, 80)
	exit.add_child(shape)
	
	var rect = ColorRect.new()
	rect.size = Vector2(40, 80)
	rect.position = Vector2(-20, -40)
	rect.color = Color(0.3, 0.7, 1.0)
	exit.add_child(rect)
	
	add_child(exit)
	exits.append(exit)

func _process(delta):
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy._physics_process(delta)

func next_level():
	level_num += 1
	_generate_level()

func get_enemy_count() -> int:
	var count = 0
	for e in enemies:
		if is_instance_valid(e) and e.get("is_alive", false):
			count += 1
	return count

func all_enemies_defeated() -> bool:
	return get_enemy_count() == 0
