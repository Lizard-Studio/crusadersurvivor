extends CharacterBody2D

@export var speed = 80.0
@export var max_health = 100

var current_health = max_health

@onready var health_bar := $HealthBar

func _ready():
	update_health_bar()
	add_to_group("player")
	
func _physics_process(_delta):
	print("Player global pos:", global_position)
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()
	
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
