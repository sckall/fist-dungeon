extends Node

# ============ 音效系统 ============

class_name AudioSystem extends Node

# 音效占位符（实际使用时替换为AudioStreamPlayer）
var sounds: Dictionary = {}

func _ready():
	pass

func play_sound(sound_name: String):
	print("播放音效: %s" % sound_name)
	# 实际使用时：
	# if sounds.has(sound_name):
	#     sounds[sound_name].play()

# 音效列表
func play_attack():
	play_sound("attack")

func play_jump():
	play_sound("jump")

func play_hurt():
	play_sound("hurt")

func play_pickup():
	play_sound("pickup")

func play_die():
	play_sound("die")

func play_level_up():
	play_sound("level_up")

func play_skill():
	play_sound("skill")

func play_boss():
	play_sound("boss")

func play_victory():
	play_sound("victory")
