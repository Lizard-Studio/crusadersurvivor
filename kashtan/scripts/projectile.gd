extends Node2D

@onready var sprite = $Sprite2D

var target: Node2D
var current_speed: float
var damage: int
var base_speed: float
var acceleration: float

func setup_projectile(enemy, dmg, speed, accel):
	target = enemy
	damage = dmg
	base_speed = speed
	current_speed = base_speed
	acceleration = accel

func _physics_process(delta):
	if !is_instance_valid(target) or target == null:
		queue_free()
		return
	
	var to_target = target.global_position - global_position
	var distance = to_target.length()
	var time_to_hit = distance / current_speed
	var predicted_position = target.global_position + target.velocity * time_to_hit
	
	var direction = (predicted_position - global_position).normalized()
	
	current_speed *= acceleration
	
	global_position += direction * current_speed * delta
	rotation = direction.angle()
	
	if distance < 10:
		queue_free()
		if target.has_method("take_damage"):
			target.take_damage(damage)
		
