extends Node2D

# ============ 游戏主控制器 ============

var player: CharacterBody2D
var dungeon: Node2D
var level: int = 1
var defeated_enemies: int = 0

# UI
var hud_layer: CanvasLayer
var hp_fill: ColorRect
var hp_label: Label
var progress_label: Label
var state_label: Label
var damage_flash: ColorRect
var _last_hp: int = 4

func _ready() -> void:
	_create_world()
	_create_hud()
	_connect_signals()

func _create_world() -> void:
	# 创建地牢
	dungeon = Node2D.new()
	dungeon.name = "Dungeon"
	add_child(dungeon)
	_generate_level()

	# 创建玩家
	player = load("res://scripts/Player.gd").new()
	player.position = Vector2(100, 480)
	add_child(player)

	# 相机
	var camera = Camera2D.new()
	camera.enabled = true
	camera.zoom = Vector2(1.3, 1.3)
	camera.position = player.position
	add_child(camera)

func _create_hud() -> void:
	hud_layer = CanvasLayer.new()
	add_child(hud_layer)

	# 受伤闪屏
	damage_flash = ColorRect.new()
	damage_flash.position = Vector2.ZERO
	damage_flash.size = Vector2(2000, 1200)
	damage_flash.color = Color(0.95, 0.15, 0.15, 0.0)
	hud_layer.add_child(damage_flash)

	# 面板
	var panel = ColorRect.new()
	panel.size = Vector2(600, 90)
	panel.position = Vector2(15, 12)
	panel.color = Color(0.01, 0.02, 0.04, 0.88)
	hud_layer.add_child(panel)

	var panel_border = ColorRect.new()
	panel_border.size = panel.size + Vector2(4, 4)
	panel_border.position = panel.position - Vector2(2, 2)
	panel_border.color = Color(0.23, 0.30, 0.47, 0.9)
	hud_layer.add_child(panel_border)

	# 标题
	var title = Label.new()
	title.position = Vector2(30, 18)
	title.text = "PIXEL DUNGEON"
	title.add_theme_color_override("font_color", Color(0.99, 0.89, 0.31))
	hud_layer.add_child(title)

	# HP条
	var hp_bg = ColorRect.new()
	hp_bg.position = Vector2(30, 45)
	hp_bg.size = Vector2(180, 14)
	hp_bg.color = Color(0.16, 0.07, 0.10, 0.95)
	hud_layer.add_child(hp_bg)

	hp_fill = ColorRect.new()
	hp_fill.position = hp_bg.position + Vector2(2, 2)
	hp_fill.size = Vector2(176, 10)
	hp_fill.color = Color(0.92, 0.24, 0.30)
	hud_layer.add_child(hp_fill)

	hp_label = Label.new()
	hp_label.position = Vector2(220, 42)
	hp_label.add_theme_color_override("font_color", Color(1, 0.88, 0.88))
	hud_layer.add_child(hp_label)

	# 进度
	progress_label = Label.new()
	progress_label.position = Vector2(30, 68)
	progress_label.add_theme_color_override("font_color", Color(0.65, 0.95, 0.78))
	hud_layer.add_child(progress_label)

	# 状态
	state_label = Label.new()
	state_label.position = Vector2(350, 42)
	state_label.add_theme_color_override("font_color", Color(0.95, 0.76, 0.31))
	hud_layer.add_child(state_label)

	_update_hud()

func _connect_signals() -> void:
	player.died.connect(_on_player_died)
	player.health_changed.connect(_on_health_changed)

func _physics_process(delta: float) -> void:
	_process_items()
	_process_enemy_damage()
	_process_exit()
	_update_effects(delta)
	_update_hud()

func _process_items() -> void:
	if not dungeon or not dungeon.has("items"):
		return

	var items = dungeon.get("items")
	for item in items.duplicate():
		if is_instance_valid(item) and player.position.distance_to(item.position) < 22:
			_collect_item(item)

func _process_enemy_damage() -> void:
	if not dungeon or not dungeon.has("enemies"):
		return

	var enemies = dungeon.get("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy) and player.position.distance_to(enemy.position) < 20:
			player.take_damage(1)

func _process_exit() -> void:
	if not dungeon or not dungeon.has("exit_door"):
		return

	var exit_door = dungeon.get("exit_door")
	var enemies = dungeon.get("enemies")
	
	if enemies.is_empty() and is_instance_valid(exit_door) and player.position.distance_to(exit_door.position) < 28:
		_next_level()

func _collect_item(item: Area2D) -> void:
	match item.name:
		"mushroom":
			player.heal(1)
		"bottle":
			player.heal(2)
	
	var items = dungeon.get("items")
	items.erase(item)
	item.queue_free()

func _next_level() -> void:
	level += 1
	defeated_enemies = 0
	_generate_level()
	player.position = Vector2(100, 480)

func _generate_level() -> void:
	# 清空
	for child in dungeon.get_children():
		child.queue_free()
	
	if not dungeon.has("platforms"):
		dungeon.set("platforms", [])
	if not dungeon.has("items"):
		dungeon.set("items", [])
	if not dungeon.has("enemies"):
		dungeon.set("enemies", [])
	
	var platforms = dungeon.get("platforms")
	var items = dungeon.get("items")
	var enemies = dungeon.get("enemies")
	
	# 地面
	var floor = StaticBody2D.new()
	floor.position = Vector2(640, 560)
	var fs = CollisionShape2D.new()
	fs.shape = RectangleShape2D.new()
	fs.shape.size = Vector2(1280, 80)
	floor.add_child(fs)
	var fr = ColorRect.new()
	fr.size = Vector2(1280, 80)
	fr.color = Color(0.2, 0.15, 0.1)
	floor.add_child(fr)
	dungeon.add_child(floor)
	platforms.append(floor)

	# 平台
	var plat_pos = [
		Vector2(250, 450), Vector2(450, 380), Vector2(650, 420),
		Vector2(850, 350), Vector2(1050, 400)
	]
	
	for pos in plat_pos:
		var p = StaticBody2D.new()
		p.position = pos
		var ps = CollisionShape2D.new()
		ps.shape = RectangleShape2D.new()
		ps.shape.size = Vector2(100, 20)
		p.add_child(ps)
		var pr = ColorRect.new()
		pr.size = Vector2(100, 20)
		pr.color = Color(0.3, 0.4, 0.25)
		p.add_child(pr)
		dungeon.add_child(p)
		platforms.append(p)

	# 敌人
	var enemy_data = [
		{"type": "slime", "pos": Vector2(450, 320), "color": Color(0.3, 0.7, 0.3)},
		{"type": "bat", "pos": Vector2(650, 150), "color": Color(0.4, 0.3, 0.5)},
		{"type": "goblin", "pos": Vector2(850, 280), "color": Color(0.4, 0.5, 0.3)}
	]
	
	for e in enemy_data:
		var en = Node2D.new()
		en.position = e.pos
		en.set_meta("hp", 2)
		en.set_meta("is_alive", true)
		en.set_meta("type", e.type)
		
		var eb = ColorRect.new()
		eb.size = Vector2(28, 28)
		eb.position = Vector2(-14, -14)
		eb.color = e.color
		en.add_child(eb)
		
		dungeon.add_child(en)
		enemies.append(en)

func _on_player_died() -> void:
	player.position = Vector2(100, 480)

func _on_health_changed(_current: int, _max: int) -> void:
	if _current < _last_hp:
		damage_flash.color.a = 0.25
	_last_hp = _current

func _update_effects(delta: float) -> void:
	damage_flash.color.a = move_toward(damage_flash.color.a, 0.0, 1.2 * delta)

func _update_hud() -> void:
	if not is_instance_valid(player):
		return

	var hp_ratio := clamp(float(player.hp) / max(1.0, float(player.max_hp)), 0.0, 1.0)
	hp_fill.size.x = 176.0 * hp_ratio
	
	var hp_color = Color(0.92, 0.22, 0.30).lerp(Color(0.95, 0.76, 0.30), 1.0 - hp_ratio)
	hp_fill.color = hp_color
	
	hp_label.text = "生命 %d / %d" % [player.hp, player.max_hp]
	
	var enemies = []
	if dungeon and dungeon.has("enemies"):
		enemies = dungeon.get("enemies")
	progress_label.text = "关卡 %d  剩余敌人 %d  已击败 %d" % [level, enemies.size(), defeated_enemies]
	
	var exit_status = "已开启" if enemies.is_empty() else "封锁中"
	state_label.text = "出口 %s" % exit_status

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		defeated_enemies = 0
		_generate_level()
		player.position = Vector2(100, 480)
