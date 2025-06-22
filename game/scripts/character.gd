extends CharacterBody2D

@export var speed = 80.0
@export var max_health = 100

var current_health = max_health

@onready var health_bar := $HealthBar
@onready var animated_sprite := $AnimatedSprite2D

var last_direction := "front" # "front", "back", "side"
var last_side_right := true

func _ready():
	update_health_bar()
	add_to_group("player")
	
func _physics_process(_delta):
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
