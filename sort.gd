extends Area2D

var speed = 800
var direction = Vector2.ZERO

func _physics_process(delta):
	# Le projectile avance dans sa direction
	position += direction * speed * delta

# Pense à connecter le signal "body_entered" pour détruire le sort 
# quand il touche un rocher ou un ennemi !
func _on_body_entered(body):
	# On vérifie si l'objet touché est dans le groupe "ennemis"
	if body.is_in_group("ennemis"):
		body.queue_free()   # L'ennemi disparaît
		queue_free()        # Le sort disparaît aussi
		get_tree().current_scene.ajouter_score_ennemi()
