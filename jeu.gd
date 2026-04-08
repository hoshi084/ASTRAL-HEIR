extends Node2D

var cristaux_allumes = 0
const LIMITE_CRISTAUX = 4
var partie_lancee = false
var peut_selectionner = false

func _ready():
	$CameraMenu.make_current()
	$personage.hide()
	$personage.process_mode = Node.PROCESS_MODE_DISABLED
	$menuDemarrage/Control/ButtonPlay.pressed.connect(_on_play_clique)
	$menuDemarrage/Control/ButtonLancer.pressed.connect(_on_lancer_clique)
	
	$barreStat/StatBar.hide() # Cache la progressbar
	
	peut_selectionner = false
	await get_tree().create_timer(1.0).timeout
	

func _on_play_clique():
	# On cache juste le bouton Play et le texte, mais on garde le menu affiché
	$menuDemarrage/Control/TextureRect.hide() # Cache l'image de fond
	$menuDemarrage/Control/nomJeu.hide()       # Cache le titre du jeu
	$menuDemarrage/Control/ButtonPlay.hide()  # Cache le bouton Play
	$menuDemarrage/Control/InstructionLabel.show()
	
	peut_selectionner = true

func mettre_a_jour_compteur(valeur):
	cristaux_allumes += valeur
	$menuDemarrage/Control/InstructionLabel.text = "Cristaux : " + str(cristaux_allumes) + " / " + str(LIMITE_CRISTAUX)
	
	# On montre le bouton LANCER uniquement quand on a exactement 4 cristaux
	if cristaux_allumes == LIMITE_CRISTAUX:
		$menuDemarrage/Control/ButtonLancer.show()
	else:
		$menuDemarrage/Control/ButtonLancer.hide()

func _on_lancer_clique():
	
	$barreStat/StatBar.show() # Affiche la progressbar
	
	var liste_cristaux = []
	
	# ÉTAPE 1 : On boucle sur tous les cristaux
	for dossier in $EmplacementsSteles.get_children():
		var cristal = dossier.get_node_or_null("Cristal")
		if cristal:
			# SI le cristal est allumé, on l'ajoute à notre liste pour la téléportation
			if cristal.est_allume:
				liste_cristaux.append(cristal)
			
			# Dans tous les cas, on éteint la lumière rouge d'alerte
			var lumiere = cristal.get_node_or_null("LumiereRouge")
			if lumiere:
				lumiere.enabled = false
	
	# ÉTAPE 2 : On vérifie si on a bien trouvé nos cristaux
	if liste_cristaux.size() > 0:
		var cristal_cible = liste_cristaux.pick_random()
		# On utilise ta nouvelle valeur de décalage (120)
		$personage.global_position = cristal_cible.global_position + Vector2(0, 120)
		
		# On active le personnage et la caméra
		$personage.show()
		$personage.process_mode = Node.PROCESS_MODE_INHERIT
		$personage/Camera2Dperso.make_current()
		
		# On cache l'interface de sélection
		$menuDemarrage/Control/InstructionLabel.hide()
		$menuDemarrage/Control/ButtonLancer.hide()
		$menuDemarrage.hide()
		$Timer.start()
		partie_lancee = true
	else:
		print("Erreur : Aucun cristal n'est allumé dans la liste !")


var ennemi_scene = preload("res://ennemi.tscn")

func _on_timer_timeout():
	# 1. On parcourt la liste de TOUS les enfants du nœud EmplacementsSteles
	for stele in $EmplacementsSteles.get_children():
		
		# 2. On récupère le nœud "Cristal" qui est dans la stèle
		var cristal = stele.get_node_or_null("Cristal")
		
		# 3. Vérification de sécurité : on s'assure que le cristal existe
		# ET qu'il n'est pas encore allumé (est_allume == false)
		if cristal != null and cristal.est_allume == false:
			
			# 4. On crée une nouvelle instance de l'ennemi (l'araignée)
			var nouveau_monstre = ennemi_scene.instantiate()
			
			# 5. On l'ajoute comme enfant de EmplacementsSteles pour éviter les décalages
			$EmplacementsSteles.add_child(nouveau_monstre)
			
			# 6. On place le monstre exactement sur la position de la stèle
			nouveau_monstre.global_position = stele.global_position
