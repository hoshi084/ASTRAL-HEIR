extends CharacterBody2D
@export var sort_scene : PackedScene

@export var speed = 600 # How fast the player will move (pixels/sec).
var screen_size

# on recupère la barre de mana
@onready var mana_bar = get_tree().current_scene.get_node("barreStat/StatBar/ManaBar")
@onready var nbr_arm = get_tree().current_scene.get_node("barreStat/StatBar/Label")

const pv_max = 100
var pv: int = 100

const mana_max = 100
var mana: int = 100

var a_potion_vie : bool = true # Possède la potion au début
var a_potion_mana : bool = true # Possède la potion au début

@onready var cooldown_sort = $CooldownSort

@onready var cooldown_bar = get_node("../barreStat/StatBar/%CooldownBar")


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	
	cooldown_bar.max_value = cooldown_sort.wait_time
	cooldown_bar.value = cooldown_bar.max_value


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
		
	if not cooldown_sort.is_stopped():
		# Le timer tourne : la barre se remplit
		# (wait_time - time_left) donne le temps écoulé
		cooldown_bar.value = cooldown_sort.wait_time - cooldown_sort.time_left
	else:
		# Le timer est arrêté : la barre est pleine (prêt à tirer)
		cooldown_bar.value = cooldown_sort.wait_time

	# Ton code de tir
	if Input.is_action_pressed("click_gauche"):
		tirer()
		
	move_and_slide() # Cette fonction utilise 'velocity' et gère les collisions toute seule
	
func _input(event):
	if event.is_action_pressed("potion_vie"): # On va configurer cette touche
		utiliser_potion("potion_vie")
	if event.is_action_pressed("potion_mana"): # On va configurer cette touche
		utiliser_potion("potion_mana")

func utiliser_potion(potion):
	if a_potion_vie || a_potion_mana:
		
		if potion == "potion_vie" && a_potion_vie:
			
			pv += 25
			# On s'assure de ne pas dépasser le maximum 
			if pv > pv_max:
				pv = pv_max
				
			a_potion_vie = false # Potion de vie consommée !
			print("Potion de vie utilisée ! PV actuels : ", pv)
			
			# Mise à jour visuelle de ta barre de vie
			get_tree().current_scene.get_node("barreStat").mettre_a_jour_pv_personnage(pv)
			
			get_node("../barreStat/%Potion").hide()
			
		elif potion == "potion_mana" && a_potion_mana:
			mana += 25
			# On s'assure de ne pas dépasser le maximum
			if mana > mana_max:
				mana = mana_max
				
			a_potion_mana = false # Potion de mana consommée !
			print("Potion de mana utilisée ! Mana actuel : ", mana)
			
			# Mise à jour visuelle de ta barre de vie
			get_tree().current_scene.get_node("barreStat").mettre_a_jour_mana_personnage(mana)
			
			get_node("../barreStat/%Potion_Mana").hide()
		# Optionnel : Cacher l'icône de la potion dans ton UI
		# %IconePotion.hide() 
	else:
		print("Plus de potion disponible !")
		
func tirer():
	# On ajoute une condition : est-ce que le timer est arrêté ?
	if mana_bar.value >= 6 and cooldown_sort.is_stopped():
		var sort_instance = sort_scene.instantiate()
		
		# On consomme le mana
		mana_bar.value -= 6
		
		# On lance le cooldown
		cooldown_sort.start()
		
		if nbr_arm.text == "1":
			sort_instance.position = position 
			sort_instance.direction = (get_global_mouse_position() - global_position).normalized()
			get_parent().add_child(sort_instance)
		else:
			print("test")
		
		
		print("Sort lancé ! Prochain tir dans ", cooldown_sort.wait_time, "s")
	elif not cooldown_sort.is_stopped():
		print("Sort en recharge...")
	else:
		print("Pas assez de mana !")
	
func recevoir_degats(montant : int):
	pv -= montant
	if pv < 0:
		pv = 0
	
	get_tree().current_scene.get_node("barreStat").mettre_a_jour_pv_personnage(pv)
	
	get_tree().current_scene.verifier_fin_du_jeu()
