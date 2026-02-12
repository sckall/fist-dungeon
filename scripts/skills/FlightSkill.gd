extends SkillBase

# ============ 飞行技能 ============

class_name FlightSkill extends SkillBase

var double_jump_count: int = 1

func _init():
	skill_name = "飞行"
	description = "二段跳"
	cooldown = 0.5
	mana_cost = 5

func _perform_skill(user: Node2D, target: Vector2) -> void:
	if user is CharacterBody2D:
		user.velocity.y = -400
		_create_effect(user.position)
		print("飞行!")

func _create_effect(pos: Vector2):
	var rect = ColorRect.new()
	rect.size = Vector2(20, 20)
	rect.position = pos - Vector2(10, 10)
	rect.color = Color(0.5, 0.8, 1.0, 0.5)
	
	var tween = rect.create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, 0.3)
	tween.tween_callback(rect.queue_free)
	
	user.get_parent().add_child(rect)
