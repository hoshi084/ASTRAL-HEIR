extends Node2D
var record : float = 0.0
const SAVE_PATH = "user://record.save"

var cristaux_allumes = 0
const LIMITE_CRISTAUX = 4
var partie_lancee = false
var peut_selectionner = false

var ennemi_scene = preload("res://ennemi.tscn")
var chasseur_scene = preload("res://ennemi_2.tscn")


var score : float = 0.0
@onready var score_label = $barreStat/StatBar2/ScoreLabel 

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
	
	charger_record()
	
func _process(delta):
	if partie_lancee:
		# On calcule le gain : 25 points par cristal par seconde
		var gain_par_seconde = cristaux_allumes * 25
		
		# On ajoute au score (delta permet d'avoir un ajout fluide par seconde)
		score += gain_par_seconde * delta
		
		_mettre_a_jour_affichage_score()

func _mettre_a_jour_affichage_score():
	# On utilise floor() pour afficher un chiffre rond
	$barreStat/StatBar2/ScoreLabel.text = str(floor(score))
	
func ajouter_score_ennemi():
	score += 60
	_mettre_a_jour_affichage_score()

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
	verifier_fin_du_jeu()

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
		# --- LIGNE À RAJOUTER CI-DESSOUS ---
		var cristal = stele.get_node_or_null("Cristal") 
		
		var nouveau_monstre
		if randf() > 0.7: 
			nouveau_monstre = chasseur_scene.instantiate()
		else:
			nouveau_monstre = ennemi_scene.instantiate()
			
		# Maintenant "cristal" existe, donc cette ligne fonctionnera :
		if cristal != null and cristal.est_allume == false:
			add_child(nouveau_monstre) # Mieux : add_child direct pour éviter les bugs de position
			nouveau_monstre.global_position = stele.global_position

# Dans jeu.gd

func verifier_fin_du_jeu():
	var game_over = false
	
	# CONDITION 1 : Plus de cristaux allumés
	if partie_lancee and cristaux_allumes <= 0:
		game_over = true
		print("Défaite : Tous les cristaux sont éteints !")

	# CONDITION 2 : Le joueur est mort (PV à 0)
	if $personage.pv <= 0:
		game_over = true
		print("Défaite : Le joueur n'a plus de PV !")

	if game_over:
		declencher_game_over()

func declencher_game_over():
	partie_lancee = false
	get_tree().paused = true
	
	# Vérification du record
	var nouveau_record = false
	if score > record:
		record = score
		sauvegarder_record()
		nouveau_record = true
	
	# Affichage sur l'écran Game Over
	# Assure-toi d'avoir ces deux Labels dans ton MenuGameOver
	var label_score = $CanvasLayer/MenuGameOver/VBoxContainer/ScoreFinalLabel
	var label_record = $CanvasLayer/MenuGameOver/VBoxContainer/ScoreRecord
	
	label_score.text = "Score : " + str(floor(score))
	
	if nouveau_record:
		label_record.text = "NOUVEAU RECORD ! : " + str(floor(record))
		label_record.modulate = Color.GOLD # Petit effet sympa en doré
	else:
		label_record.text = "Meilleur Score : " + str(floor(record))
		label_record.modulate = Color.WHITE

	$CanvasLayer/MenuGameOver.show()
	$barreStat.hide()
	$MiniMapUI.hide()


func _on_button_rejouer_pressed() -> void:
	print("Bouton cliqué !")
	get_tree().paused = false # Enlever la pause
	get_tree().reload_current_scene() # Relance tout le jeu proprement

func sauvegarder_record():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(record)
	file.close()

func charger_record():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		record = file.get_var()
		file.close()
