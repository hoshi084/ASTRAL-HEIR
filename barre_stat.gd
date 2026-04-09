extends TextureProgressBar

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