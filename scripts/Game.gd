extends Node2D

# ============ 游戏主控制器 ============

# 预加载所有类
const PlayerScript = preload("res://scripts/Player.gd")
const DungeonScript = preload("res://scripts/dungeon/DungeonSystem.gd")
const GameUIScript = preload("res://scripts/ui/GameUI.gd")

var player: Node2D
var dungeon: Node2D
var ui: Node2D

var current_level: int = 1
var is_game_over: bool = false

func _ready():
	print("========================================")
	print("  🎮 拳皇地牢 - 游戏启动")
	print("========================================")
	
	# 创建地牢系统
	dungeon = DungeonScript.new()
	add_child(dungeon)
	
	# 创建玩家
	player = PlayerScript.new()
	player.position = Vector2(100, 400)
	add_child(player)
	
	# 创建UI
	ui = GameUIScript.new()
	add_child(ui)
	
	# 连接玩家信号
	player.died.connect(_on_player_died)
	
	print("游戏就绪! 按 回车 攻击, W上 PgUp Home 使用技能")

func _process(delta):
	# 检测玩家拾取物品
	if is_instance_valid(player):
		_check_item_pickup()
		
		# 检测出口
		_check_exit()
		
		# 检测敌人碰撞
		_check_enemy_collision()

func _check_item_pickup():
	if not is_instance_valid(dungeon):
		return
		
	for item in dungeon.items:
		if is_instance_valid(item) and player.position.distance_to(item.position) < 30:
			player.collect_item(item)
			dungeon.items.erase(item)

func _check_exit():
	if not is_instance_valid(dungeon):
		return
		
	for exit in dungeon.exits:
		if is_instance_valid(exit) and player.position.distance_to(exit.position) < 50:
			# 检查是否清完敌人
			if dungeon.all_enemies_defeated():
				_next_level()

func _check_enemy_collision():
	if not is_instance_valid(dungeon):
		return
		
	for enemy in dungeon.enemies:
		if is_instance_valid(enemy) and enemy.is_alive:
			if enemy.has_meta("damage") and player.position.distance_to(enemy.position) < 30:
				player.take_damage()

func _on_player_died():
	print("玩家死亡! 3秒后复活...")
	
	# 3秒后复活
	await get_tree().create_timer(3.0).timeout
	
	if is_instance_valid(player):
		player.hp = player.max_hp
		player.position = Vector2(100, 400)
		player.is_invincible = true
		player.invincible_timer = 2.0

func _next_level():
	current_level += 1
	player.save_system.set_level(current_level)
	player.save_system.save_game()
	
	print("=== 进入关卡 %d ===" % current_level)
	
	# 重新生成地牢
	dungeon._generate_level()

func _input(event):
	if event.is_action_pressed("pause"):
		_toggle_pause()

func _toggle_pause():
	get_tree().paused = not get_tree().paused
	
	var pause_text = Label.new()
	pause_text.text = "游戏暂停" if get_tree().paused else ""
	pause_text.position = Vector2(540, 350)
	pause_text.add_theme_font_size_override("font_size", 32)
	add_child(pause_text)
	
	await get_tree().create_timer(1.0).timeout
	pause_text.queue_free()
