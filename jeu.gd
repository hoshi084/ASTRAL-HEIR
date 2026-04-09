extends Node2D

var cristaux_allumes = 0
const LIMITE_CRISTAUX = 4
var partie_lancee = false
var peut_selectionner = false

func _ready():
	$CameraMenu.make_current()
	$personage.hide()
	$personage.process_mode = Node.PROCESS_MODE_DISABLED
	$menuDemarrage/Control/VBoxContainer/ButtonPlay.pressed.connect(_on_play_clique)
	$menuDemarrage/Control/ButtonLancer.pressed.connect(_on_lancer_clique)
	
	$barreStat/StatBar.hide()
	
	await get_tree().create_timer(1.0).timeout	

func _on_play_clique():
	# On cache juste le bouton Play et le texte, mais on garde le menu affiché
	$menuDemarrage/Control/TextureRect.hide() # Cache l'image de fond
	$menuDemarrage/Control/VBoxContainer/nomJeu.hide()       # Cache le titre du jeu
	$menuDemarrage/Control/VBoxContainer/ButtonPlay.hide()  # Cache le bouton Play
	$menuDemarrage/Control/InstructionLabel.show()
	
	peut_selectionner = true

func mettre_a_jour_compteur(valeur):
	cristaux_allumes += valeur
	
	$menuDemarrage/Control/InstructionLabel.text = "Cristaux : " + str(cristaux_allumes) + " / " + str(LIMITE_CRISTAUX)
	
	if cristaux_allumes == LIMITE_CRISTAUX:
		$menuDemarrage/Control/ButtonLancer.show()
	else:
		$menuDemarrage/Control/ButtonLancer.hide()

func _on_lancer_clique():
	$barreStat/StatBar.show()
	$barreStat/StatBar.enregistrer_cristaux_allumes() # 🔥 IMPORTANT
	
	var liste_cristaux = []
	
	for dossier in $EmplacementsSteles.get_children():
		var cristal = dossier.get_node_or_null("Cristal")
		if cristal:
			if cristal.est_allume:
				liste_cristaux.append(cristal)
			
			var lumiere = cristal.get_node_or_null("LumiereRouge")
			if lumiere:
				lumiere.enabled = false
	
	if liste_cristaux.size() > 0:
		var cristal_cible = liste_cristaux.pick_random()
		$personage.global_position = cristal_cible.global_position + Vector2(0, 120)
		
		$personage.show()
		$personage.process_mode = Node.PROCESS_MODE_INHERIT
		$personage/Camera2Dperso.make_current()
		
		$menuDemarrage.hide()
		
		$Timer.start()
		partie_lancee = true
	else:
		print("Erreur : Aucun cristal allumé !")

var ennemi_scene = preload("res://ennemi.tscn")

func _on_timer_timeout():
	for stele in $EmplacementsSteles.get_children():
		var cristal = stele.get_node_or_null("Cristal")
		
		if cristal != null and cristal.est_allume == false:
			var nouveau_monstre = ennemi_scene.instantiate()
			$EmplacementsSteles.add_child(nouveau_monstre)
			nouveau_monstre.global_position = stele.global_position
