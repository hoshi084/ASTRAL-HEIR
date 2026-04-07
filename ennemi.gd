extends CharacterBody2D

@export var vitesse = 500
var cible = null

@onready var nav_agent = $NavigationAgent2D # Ton nouveau GPS

func _physics_process(_delta):
	rechercher_cible()
	
	if cible:
		# On donne la destination finale au GPS
		nav_agent.target_position = cible.global_position
		
		# On demande au GPS : "C'est quoi la prochaine étape pour faire le tour ?"
		var prochaine_position = nav_agent.get_next_path_position()
		
		# On calcule la direction vers cette étape, pas vers la cible finale
		var direction = (prochaine_position - global_position).normalized()
		
		velocity = direction * vitesse
		move_and_slide()
			
func _on_timer_timeout():
	rechercher_cible()

func rechercher_cible():
	var distance_min = 999999
	var cristal_proche = null
	
	# On récupère le nœud qui contient tous tes cristaux
	var emplacements = get_tree().current_scene.get_node("EmplacementsSteles")
	
	for dossier in emplacements.get_children():
		var cristal = dossier.get_node_or_null("Cristal")
		
		# On ne cible que les cristaux allumés
		if cristal and cristal.est_allume:
			var distance = global_position.distance_to(cristal.global_position)
			if distance < distance_min:
				distance_min = distance
				cristal_proche = cristal
	
	cible = cristal_proche
