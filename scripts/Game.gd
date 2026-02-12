extends Node2D

# ============ 游戏主控制器 ============

var player: Node = null
var dungeon: Node = null
var ui: Node = null

var current_level: int = 1
var is_game_over: bool = false

func _ready():
	print("========================================")
	print("  🎮 拳皇地牢 - 游戏启动")
	print("========================================")
	
	# 动态加载地牢系统
	var dungeon_script = load("res://scripts/dungeon/DungeonSystem.gd")
	if dungeon_script:
		dungeon = dungeon_script.new()
		add_child(dungeon)
	
	# 动态加载玩家
	var player_script = load("res://scripts/Player.gd")
	if player_script:
		player = player_script.new()
		player.position = Vector2(100, 400)
		add_child(player)
	
	# 动态加载UI
	var ui_script = load("res://scripts/ui/GameUI.gd")
	if ui_script:
		ui = ui_script.new()
		add_child(ui)
	
	print("游戏就绪!")

func _process(delta):
	if not player or not dungeon:
		return
	
	# 检测玩家拾取物品
	_check_item_pickup()
	
	# 检测出口
	_check_exit()
	
	# 检测敌人碰撞
	_check_enemy_collision()

func _check_item_pickup():
	if not dungeon or not dungeon.has("items"):
		return
	
	var items = dungeon.get("items")
	for item in items:
		if is_instance_valid(item) and player.position.distance_to(item.position) < 30:
			if player.has_method("collect_item"):
				player.collect_item(item)
			items.erase(item)

func _check_exit():
	if not dungeon or not dungeon.has("exits"):
		return
	
	var exits = dungeon.get("exits")
	for exit in exits:
		if is_instance_valid(exit) and player.position.distance_to(exit.position) < 50:
			if dungeon.has_method("all_enemies_defeated") and dungeon.all_enemies_defeated():
				_next_level()

func _check_enemy_collision():
	if not dungeon or not dungeon.has("enemies"):
		return
	
	var enemies = dungeon.get("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.get("is_alive", false):
			if enemy.has_meta("damage") and player.position.distance_to(enemy.position) < 30:
				if player.has_method("take_damage"):
					player.take_damage()

func _next_level():
	current_level += 1
	if player and player.has("save_system"):
		var save = player.get("save_system")
		save.set_level(current_level)
		save.save_game()
	
	print("=== 进入关卡 %d ===" % current_level)
	
	if dungeon and dungeon.has_method("_generate_level"):
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
