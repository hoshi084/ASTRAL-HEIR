extends CharacterBody2D
@export var sort_scene : PackedScene

@export var speed = 600 # How fast the player will move (pixels/sec).
var screen_size

# on recupère la barre de mana
@onready var mana_bar = get_tree().current_scene.get_node("barreStat/StatBar/ManaBar")

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size


func _process(delta):
	var input_velocity = Vector2.ZERO 
	
	# Récupération des touches
	if Input.is_action_pressed("right"):
		input_velocity.x += 1
	if Input.is_action_pressed("left"):
		input_velocity.x -= 1
	if Input.is_action_pressed("down"):
		input_velocity.y += 1
	if Input.is_action_pressed("up"):
		input_velocity.y -= 1

	if input_velocity.length() > 0:
		velocity = input_velocity.normalized() * speed
		
		# --- GESTION DES ANIMATIONS SELON LA DIRECTION ---
		# On regarde si le mouvement est plus horizontal ou vertical
		if abs(input_velocity.x) > abs(input_velocity.y):
			if input_velocity.x > 0:
				$AnimatedSprite2D.play("droite")
			else:
				$AnimatedSprite2D.play("gauche")
		else:
			if input_velocity.y > 0:
				$AnimatedSprite2D.play("bas")
			else:
				$AnimatedSprite2D.play("haut")
	else:
		velocity = Vector2.ZERO
		$AnimatedSprite2D.stop()
		
	if Input.is_action_just_pressed("click_gauche"):
		tirer()
		
	move_and_slide() # Cette fonction utilise 'velocity' et gère les collisions toute seule
	


func tirer():
	var sort_instance = sort_scene.instantiate()
	mana_bar.value -= 6
	sort_instance.position = position 
	
	sort_instance.direction = (get_global_mouse_position() - global_position).normalized()
	
	get_parent().add_child(sort_instance)
	
