extends TextureProgressBar

<<<<<<< Updated upstream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
=======
var max_pv = 100
var pv = 100

func _ready():
	max_value = max_pv
	pv = 70
	value = pv
	
func take_damage(amount):
	pv -= amount
	pv = clamp(pv, 0, max_pv)
	value = pv
>>>>>>> Stashed changes
