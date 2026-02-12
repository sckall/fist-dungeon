extends Node2D

# ============ 游戏主控制器 ============

var player: Player
var enemies: Array = []
var platforms: Array = []
var level: int = 1
var score: int = 0

func _ready():
	_setup_world()
	_spawn_player()
	_spawn_enemies()
	_ui()

func _setup_world():
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
	add_child(floor)
	
	# 平台
	var plat_pos = [Vector2(250, 450), Vector2(450, 380), Vector2(650, 420), 
	               Vector2(850, 350), Vector2(1050, 400)]
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
		add_child(p)
		platforms.append(p)

func _spawn_player():
	player = Player.new()
	player.position = Vector2(100, 480)
	add_child(player)
	
	var pc = CollisionShape2D.new()
	pc.shape = RectangleShape2D.new()
	pc.shape.size = Vector2(32, 48)
	player.add_child(pc)
	
	var pb = ColorRect.new()
	pb.size = Vector2(32, 48)
	pb.position = Vector2(-16, -24)
	pb.color = Color(0.2, 0.5, 0.9)
	player.add_child(pb)
	
	var cam = Camera2D.new()
	cam.zoom = Vector2(1.3, 1.3)
	player.add_child(cam)

func _spawn_enemies():
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
		
		add_child(en)
		enemies.append(en)

func _ui():
	var l = Label.new()
	l.text = "🎮 拳皇地牢 | 关卡:%d | 得分:%d\n操作: ←→ 移动 | 空格 跳跃" % [level, score]
	l.position = Vector2(20, 20)
	l.add_theme_font_size_override("font_size", 16)
	add_child(l)

func _process(delta):
	if not player or not player.is_alive: return
	
	# 敌人简单AI
	for en in enemies:
		if en.get_meta("is_alive"):
			var dir = (player.position - en.position).normalized()
			en.position += dir * 40.0 * delta
			
			# 检测碰撞
			if player.position.distance_to(en.position) < 30:
				player.take_damage()
	
	# 敌人死亡检测
	for i in range(enemies.size() - 1, -1, -1):
		var en = enemies[i]
		if en.get_meta("hp") <= 0:
			en.set_meta("is_alive", false)
			en.queue_free()
			enemies.remove_at(i)
			score += 10
			
			# 检测是否全灭
			var all_dead = true
			for e in enemies:
				if e.get_meta("is_alive"):
					all_dead = false
					break
			if all_dead:
				level += 1
				_restart_level()

func _restart_level():
	# 清除敌人
	for en in enemies:
		en.queue_free()
	enemies.clear()
	
	# 重置玩家
	player.position = Vector2(100, 480)
	player.hp = player.max_hp
	
	# 重新生成敌人
	_spawn_enemies()
	
	# 更新UI
	get_child(get_child_count() - 1).queue_free()
	_ui()
