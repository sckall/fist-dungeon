extends Node2D

# ============ 游戏主控制器 - 最小测试版 ============

func _ready():
	print("========================================")
	print("  🎮 拳皇地牢 - 测试版")
	print("========================================")
	
	# 创建玩家（简单色块）
	var player = CharacterBody2D.new()
	player.position = Vector2(640, 360)
	player.name = "Player"
	add_child(player)
	
	# 玩家身体
	var body = ColorRect.new()
	body.size = Vector2(32, 48)
	body.position = Vector2(-16, -24)
	body.color = Color(0.2, 0.6, 1.0)
	player.add_child(body)
	
	# 相机
	var camera = Camera2D.new()
	camera.zoom = Vector2(1.5, 1.5)
	player.add_child(camera)
	
	# 创建地面
	var floor = StaticBody2D.new()
	floor.position = Vector2(640, 550)
	
	var shape = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(1280, 100)
	floor.add_child(shape)
	
	var rect = ColorRect.new()
	rect.size = Vector2(1280, 100)
	rect.color = Color(0.25, 0.2, 0.15)
	floor.add_child(rect)
	
	add_child(floor)
	
	# 创建几个平台
	for i in range(5):
		var plat = StaticBody2D.new()
		plat.position = Vector2(200 + i * 200, 400 + randi() % 100)
		
		var p_shape = CollisionShape2D.new()
		p_shape.shape = RectangleShape2D.new()
		p_shape.shape.size = Vector2(100, 20)
		plat.add_child(p_shape)
		
		var p_rect = ColorRect.new()
		p_rect.size = Vector2(100, 20)
		p_rect.color = Color(0.35, 0.45, 0.25)
		plat.add_child(p_rect)
		
		add_child(plat)
	
	# 创建敌人
	var enemy = _create_enemy("slime", 400, 500)
	add_child(enemy)
	
	var enemy2 = _create_enemy("bat", 600, 200)
	add_child(enemy2)
	
	var enemy3 = _create_enemy("goblin", 800, 500)
	add_child(enemy3)
	
	# 创建UI
	var ui = Control.new()
	ui.name = "UI"
	add_child(ui)
	
	var label = Label.new()
	label.text = "🎮 拳皇地牢 - 测试版\n按 空格 跳跃 | 按 回车 攻击\n清完敌人进入下一关"
	label.position = Vector2(440, 50)
	label.add_theme_font_size_override("font_size", 20)
	ui.add_child(label)
	
	var hp_label = Label.new()
	hp_label.name = "HPLabel"
	hp_label.text = "❤️ HP: 5 | 💰 金币: 0"
	hp_label.position = Vector2(50, 50)
	hp_label.add_theme_font_size_override("font_size", 18)
	ui.add_child(hp_label)
	
	print("游戏创建完成!")
	print("按 F5 重新运行")

func _create_enemy(type: String, x: float, y: float) -> Node2D:
	var enemy = Node2D.new()
	enemy.position = Vector2(x, y)
	enemy.set_meta("type", type)
	enemy.set_meta("hp", 3)
	enemy.set_meta("is_alive", true)
	
	match type:
		"slime":
			var body = ColorRect.new()
			body.size = Vector2(32, 24)
			body.position = Vector2(-16, -24)
			body.color = Color(0.3, 0.7, 0.3)
			enemy.add_child(body)
		"bat":
			var body = ColorRect.new()
			body.size = Vector2(24, 16)
			body.position = Vector2(-12, -8)
			body.color = Color(0.4, 0.3, 0.5)
			enemy.add_child(body)
		"goblin":
			var body = ColorRect.new()
			body.size = Vector2(28, 36)
			body.position = Vector2(-14, -36)
			body.color = Color(0.4, 0.5, 0.3)
			enemy.add_child(body)
	
	return enemy

func _process(delta):
	pass
