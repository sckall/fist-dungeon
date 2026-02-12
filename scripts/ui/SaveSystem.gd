extends Node

# ============ 存档系统 ============

class_name SaveSystem extends Node

var save_data: Dictionary = {
	"level": 1,
	"gold": 0,
	"skills_unlocked": [],
	"weapons_unlocked": ["fist"],
	"current_skill": 0,
	"high_score": 0,
	"deaths": 0
}

var save_file_path: String = "user://save.dat"
var auto_save_enabled: bool = true

func _ready():
	load_game()

func save_game() -> void:
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file:
		var json = JSON.stringify(save_data)
		file.store_string(json)
		print("存档已保存: %s" % save_file_path)
	else:
		print("存档失败!")

func load_game() -> bool:
	if FileAccess.file_exists(save_file_path):
		var file = FileAccess.open(save_file_path, FileAccess.READ)
		if file:
			var json = file.get_as_text()
			var data = JSON.parse_string(json)
			if data:
				save_data = data
				print("读取存档: 关卡%d 金币%d" % [save_data["level"], save_data["gold"]])
				return true
	return false

func delete_save() -> void:
	if FileAccess.file_exists(save_file_path):
		DirAccess.remove_absolute(save_file_path)
		print("存档已删除")

# 金币管理
func add_gold(amount: int) -> void:
	save_data["gold"] += amount
	_auto_save()

func spend_gold(amount: int) -> bool:
	if save_data["gold"] >= amount:
		save_data["gold"] -= amount
		_auto_save()
		return true
	return false

func lose_half_gold() -> void:
	var loss = save_data["gold"] / 2
	save_data["gold"] -= loss
	_auto_save()
	print("死亡损失金币: %d (剩余: %d)" % [loss, save_data["gold"]])

# 关卡管理
func set_level(level: int) -> void:
	save_data["level"] = level
	_auto_save()

func next_level() -> int:
	save_data["level"] += 1
	_auto_save()
	return save_data["level"]

# 技能管理
func unlock_skill(skill_name: String) -> void:
	if not skill_name in save_data["skills_unlocked"]:
		save_data["skills_unlocked"].append(skill_name)
		_auto_save()
		print("解锁技能: %s" % skill_name)

func has_skill(skill_name: String) -> bool:
	return skill_name in save_data["skills_unlocked"]

func set_current_skill(index: int) -> void:
	save_data["current_skill"] = index
	_auto_save()

func get_current_skill() -> int:
	return save_data.get("current_skill", 0)

# 统计
func add_death() -> void:
	save_data["deaths"] += 1
	_auto_save()

func get_deaths() -> int:
	return save_data.get("deaths", 0)

func update_high_score(score: int) -> void:
	if score > save_data["high_score"]:
		save_data["high_score"] = score
		_auto_save()

# 自动存档
func _auto_save():
	if auto_save_enabled:
		save_game()

# 重置进度（用于新游戏）
func reset_progress() -> void:
	save_data = {
		"level": 1,
		"gold": 0,
		"skills_unlocked": [],
		"weapons_unlocked": ["fist"],
		"current_skill": 0,
		"high_score": 0,
		"deaths": 0
	}
	delete_save()
