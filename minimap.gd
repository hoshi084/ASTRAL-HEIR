extends CanvasLayer

@onready var panel = $Panel
@onready var subviewport = $Panel/SubViewportContainer/SubViewport
@onready var minimap_camera = $Panel/SubViewportContainer/SubViewport/Camera2D

var joueur = null

func _ready():
	subviewport.world_2d = get_viewport().world_2d
	minimap_camera.enabled = true
	minimap_camera.make_current()
	minimap_camera.zoom = Vector2(0.05, 0.05)
	panel.position = Vector2(20, 20)

func set_joueur(nouveau_joueur):
	joueur = nouveau_joueur

func _process(delta):
	if joueur != null:
		minimap_camera.global_position = joueur.global_position
