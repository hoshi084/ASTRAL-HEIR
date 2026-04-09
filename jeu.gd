extends Node2D

var cristaux_allumes = 0
const LIMITE_CRISTAUX = 4
var partie_lancee = false
var peut_selectionner = false

var ennemi_scene = preload("res://ennemi.tscn")

func _ready():
	$CameraMenu.make_current()
	$personage.hide()
	$personage.process_mode = Node.PROCESS_MODE_DISABLED
	
	$menuDemarrage/Control/VBoxContainer/ButtonPlay.pressed.connect(_on_play_clique)
	$menuDemarrage/Control/ButtonLancer.pressed.connect(_on_lancer_clique)
	
	$barreStat.hide()
	
	# cacher la minimap
	$MiniMapUI.set_joueur($personage)
	$MiniMapUI.hide()
	
	peut_selectionner = false
	await get_tree().create_timer(1.0).timeout

func _on_play_clique():
	$menuDemarrage/Control/TextureRect.hide()
	$menuDemarrage/Control/VBoxContainer/nomJeu.hide()
	$menuDemarrage/Control/VBoxContainer/ButtonPlay.hide()
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
	# on affiche la minimap
	$MiniMapUI.show()
	
	# on affiche la barre de stat
	$barreStat.show()
	$barreStat.enregistrer_cristaux_allumes()
	
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
		
		$menuDemarrage/Control/InstructionLabel.hide()
		$menuDemarrage/Control/ButtonLancer.hide()
		$menuDemarrage.hide()
		
		$Timer.start()
		partie_lancee = true
	else:
		print("Erreur : Aucun cristal n'est allumé dans la liste !")

func _on_timer_timeout():
	for stele in $EmplacementsSteles.get_children():
		var cristal = stele.get_node_or_null("Cristal")
		
		if cristal != null and cristal.est_allume == false:
			var nouveau_monstre = ennemi_scene.instantiate()
			$EmplacementsSteles.add_child(nouveau_monstre)
			nouveau_monstre.global_position = stele.global_position
