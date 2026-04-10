extends CharacterBody2D

@export var vitesse = 500
var cible = null
@onready var nav_agent = $NavigationAgent2D # Ton nouveau GPS
var cible_actuelle = null # Pour savoir quel cristal on est en train de taper
@onready var timer_attaque = $TimerAttaque # Assure-toi que le nom correspond au nœud dans ta scène

func _physics_process(_delta):
	rechercher_cible()
	if cible and is_instance_valid(cible):
		nav_agent.target_position = cible.global_position
		var prochaine_position = nav_agent.get_next_path_position()
		var direction = (prochaine_position - global_position).normalized()
		
		velocity = direction * vitesse
		move_and_slide()
			
func _on_timer_timeout():
	rechercher_cible()

func rechercher_cible():
	# On va directement chercher le nœud du joueur dans la scène
	var joueur = get_tree().current_scene.get_node_or_null("personage")
	
	if joueur:
		cible = joueur
	else:
		cible = null
	
func _on_zone_degats_area_entered(area):
	var objet = area.get_parent()
	if objet.is_in_group("cristaux"):
		cible_actuelle = objet
		timer_attaque.start() # On commence à frapper
		frapper_cible() # Premier coup immédiat

func _on_zone_degats_area_exited(area):
	if area.get_parent() == cible_actuelle:
		cible_actuelle = null
		timer_attaque.stop() # On arrête de frapper si on s'éloigne

func _on_timer_attaque_timeout():
	frapper_cible()

func frapper_cible():
	if cible_actuelle and cible_actuelle.has_method("recevoir_degats"):
		cible_actuelle.recevoir_degats(5)
