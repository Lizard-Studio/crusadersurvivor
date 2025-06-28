extends CharacterBody2D

@export var speed = 80.0
@export var max_health = 100
@export var damage = 10
@export var projectile_speed = 100.0
@export var projectile_acceleration = 1.2
@export var projectile_scene: PackedScene
@export var xp_collect_radius: float = 150.0

var current_health = max_health
var shoot_timer = 0.0

@onready var health_bar := $HealthBar
@onready var animated_sprite := $AnimatedSprite2D

var last_direction := "front"
var last_side_right := true

func _ready():
	update_health_bar()
	add_to_group("player")

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	
	velocity = input_vector * speed
	move_and_slide()
	
	if input_vector != Vector2.ZERO:
		if abs(input_vector.x) > abs(input_vector.y):
			last_direction = "side"
			last_side_right = input_vector.x > 0
			animated_sprite.animation = "run_side"
			animated_sprite.flip_h = not last_side_right
		elif input_vector.y < 0:
			last_direction = "back"
			animated_sprite.animation = "run_back"
			animated_sprite.flip_h = false
		else:
			last_direction = "front"
			animated_sprite.animation = "run_front"
			animated_sprite.flip_h = false
		animated_sprite.play()
	else:
		match last_direction:
			"side":
				animated_sprite.animation = "idle_side"
				animated_sprite.flip_h = not last_side_right
			"back":
				animated_sprite.animation = "idle_back"
				animated_sprite.flip_h = false
			"front":
				animated_sprite.animation = "idle_front"
				animated_sprite.flip_h = false
		animated_sprite.play()
	
	shoot_timer += delta
	if shoot_timer >= 1:
		shoot_timer = 0
		var nearest_enemy = find_nearest_enemy()
		if nearest_enemy:
			spawn_projectile(nearest_enemy)
	
	collect_xp_orbs(delta)

func collect_xp_orbs(delta):
	var orbs = get_tree().get_nodes_in_group("xp_orb")
	for orb in orbs:
		var distance = global_position.distance_to(orb.global_position)
		if distance < xp_collect_radius:
			if distance < 10:
				orb.queue_free()
			else:
				var direction = (global_position - orb.global_position).normalized()
				orb.position += direction * 400 * delta

func find_nearest_enemy():
	var nearest = null
	var min_dist = INF
	var space_state = get_world_2d().direct_space_state
	
	var shape = CircleShape2D.new()
	shape.radius = 200
	
	var params = PhysicsShapeQueryParameters2D.new()
	params.set_shape(shape)
	params.transform = Transform2D(0, global_position)
	params.collision_mask = 2
	params.exclude = [self]
	
	var results = space_state.intersect_shape(params)
	for result in results:
		var dist = global_position.distance_to(result.collider.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = result.collider
	
	return nearest

func spawn_projectile(target):
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = global_position
	projectile.setup_projectile(target, damage, projectile_speed, projectile_acceleration)

func take_damage(amount: int):
	current_health -= amount
	current_health = max(current_health, 0)
	update_health_bar()
	if current_health <= 0:
		die()

func update_health_bar():
	health_bar.value = current_health

func die():
	get_tree().change_scene_to_file("res://deathscreen/deathscreen.tscn")
