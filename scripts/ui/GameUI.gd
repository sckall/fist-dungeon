extends Node2D

# ============ UI系统 ============

class_name GameUI extends Control

var player: Node2D
var dungeon: Node2D
var save_system: Node

# UI元素
var hp_label: Label
var gold_label: Label
var level_label: Label
var skill_labels: Array = []
var cooldown_labels: Array = []

var hp_bar: ColorRect
var mana_bar: ColorRect

func _ready():
	_setup_ui()
	
	# 获取节点
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	# 连接信号
	if player:
		player.health_changed.connect(_on_health_changed)
		player.gold_changed.connect(_on_gold_changed)
		player.level_changed.connect(_on_level_changed)

func _setup_ui():
	# 背景
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.1, 0.5)
	bg.size = Vector2(1280, 60)
	bg.position = Vector2(0, 0)
	add_child(bg)
	
	# HP图标
	var hp_icon = Label.new()
	hp_icon.text = "❤️"
	hp_icon.position = Vector2(20, 15)
	hp_icon.add_theme_font_size_override("font_size", 24)
	add_child(hp_icon)
	
	hp_label = Label.new()
	hp_label.text = "5/5"
	hp_label.position = Vector2(55, 15)
	hp_label.add_theme_font_size_override("font_size", 20)
	add_child(hp_label)
	
	# 金币
	var gold_icon = Label.new()
	gold_icon.text = "💰"
	gold_icon.position = Vector2(130, 15)
	gold_icon.add_theme_font_size_override("font_size", 24)
	add_child(gold_icon)
	
	gold_label = Label.new()
	gold_label.text = "0"
	gold_label.position = Vector2(165, 15)
	gold_label.add_theme_font_size_override("font_size", 20)
	add_child(gold_label)
	
	# 关卡
	level_label = Label.new()
	level_label.text = "关卡 1"
	level_label.position = Vector2(220, 15)
	level_label.add_theme_font_size_override("font_size", 20)
	add_child(level_label)
	
	# 技能提示
	var skill_title = Label.new()
	skill_title.text = "技能: K-飞行 L-光束 U-地刺"
	skill_title.position = Vector2(500, 15)
	skill_title.add_theme_font_size_override("font_size", 16)
	add_child(skill_title)
	
	# 操作提示
	var controls = Label.new()
	controls.text = "移动:AD 跳跃:W 攻击:J 技能:K/L/U"
	controls.position = Vector2(800, 15)
	controls.add_theme_font_size_override("font_size", 16)
	add_child(controls)

func _on_health_changed(current, max):
	if hp_label:
		hp_label.text = "%d/%d" % [current, max]

func _on_gold_changed(amount):
	if gold_label:
		gold_label.text = str(amount)

func _on_level_changed(level):
	if level_label:
		level_label.text = "关卡 %d" % level
