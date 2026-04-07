extends Node2D

# Remplace par les valeurs que tu as notées dans l'inspecteur
var rect_vide = Rect2(1344.0, 1440.0, 64.0, 80.0) 
var rect_brillant = Rect2(1280.0, 1264.0, 64.0, 80.0)
@export var ennemi_scene : PackedScene = preload("res://ennemi.tscn")
var pv = 100

var est_allume = false

func _ready():
	# On s'assure que le cristal commence éteint
	add_to_group("cristaux")
	$Visuel.region_rect = rect_vide
	$PointLight2D.enabled = false
	$LumiereRouge.enabled = true

# Cette fonction est appelée quand on clique sur l'Area2D
func _on_area_2d_input_event(viewport, event, shape_idx):
	
	var script_principal = get_tree().current_scene
	if not script_principal.peut_selectionner:
		return
	if script_principal.partie_lancee:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		allumer_ou_eteindre()
		

func allumer_ou_eteindre():
	est_allume = !est_allume # Inverse l'état (allume si éteint, éteint si allumé)
	
	if est_allume:
		$Visuel.region_rect = rect_brillant
		$PointLight2D.enabled = true
		$LumiereRouge.enabled = false # On éteint l'alerte rouge
		$Timer.stop()
		get_tree().current_scene.mettre_a_jour_compteur(1)
	else:
		$Visuel.region_rect = rect_vide
		$PointLight2D.enabled = false
		$LumiereRouge.enabled = true # On remet l'alerte rouge
		$Timer.start()
		get_tree().current_scene.mettre_a_jour_compteur(-1)


func _on_timer_timeout():
	var script_principal = get_tree().current_scene
	if script_principal.partie_lancee and not est_allume:
		var nouveau_monstre = ennemi_scene.instantiate()
		nouveau_monstre.global_position = global_position
		script_principal.add_child(nouveau_monstre)
		
func recevoir_degats(montant):
	if est_allume:
		pv -= montant
		if pv <= 0:
			allumer_ou_eteindre() # Il s'éteint s'il n'a plus de PV
