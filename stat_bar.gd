extends CanvasLayer

@onready var pv_bar = $StatBar/PvBar
@onready var mana_bar = $StatBar/ManaBar
@onready var terror_bar = $StatBar/TerrorBar
@onready var crystal1_bar = $StatBar/Crystal1Bar
@onready var crystal2_bar = $StatBar/Crystal2Bar
@onready var crystal3_bar = $StatBar/Crystal3Bar
@onready var crystal4_bar = $StatBar/Crystal4Bar
@onready var recharge_mana = $StatBar/ManaBar/recharge_mana

var Cristal_pv1 = null
var Cristal_pv2 = null
var Cristal_pv3 = null
var Cristal_pv4 = null

func _ready():
	print("stat_bar chargé")
	
	recharge_mana.start()
	
	pv_bar.min_value = 0
	pv_bar.max_value = 100
	pv_bar.value = 100

	mana_bar.min_value = 0
	mana_bar.max_value = 100
	mana_bar.value = 100

	terror_bar.min_value = 0
	terror_bar.max_value = 100
	terror_bar.value = 0

	crystal1_bar.min_value = 0
	crystal1_bar.max_value = 100
	crystal1_bar.value = 0

	crystal2_bar.min_value = 0
	crystal2_bar.max_value = 100
	crystal2_bar.value = 0

	crystal3_bar.min_value = 0
	crystal3_bar.max_value = 100
	crystal3_bar.value = 0

	crystal4_bar.min_value = 0
	crystal4_bar.max_value = 100
	crystal4_bar.value = 0

func enregistrer_cristaux_allumes():
	var cristaux = get_tree().get_nodes_in_group("cristaux")

	Cristal_pv1 = null
	Cristal_pv2 = null
	Cristal_pv3 = null
	Cristal_pv4 = null

	var index = 0

	for cristal in cristaux:
		if cristal.est_allume:
			match index:
				0:
					Cristal_pv1 = cristal
				1:
					Cristal_pv2 = cristal
				2:
					Cristal_pv3 = cristal
				3:
					Cristal_pv4 = cristal

			index += 1

			if index >= 4:
				break

	mettre_a_jour_barres_cristaux()

func mettre_a_jour_barres_cristaux():
	crystal1_bar.value = Cristal_pv1.pv if Cristal_pv1 != null else 0
	crystal2_bar.value = Cristal_pv2.pv if Cristal_pv2 != null else 0
	crystal3_bar.value = Cristal_pv3.pv if Cristal_pv3 != null else 0
	crystal4_bar.value = Cristal_pv4.pv if Cristal_pv4 != null else 0


func _on_recharge_mana_timeout():
	mana_bar.value = min(mana_bar.max_value, mana_bar.value + 4)
	
func mettre_a_jour_pv_personnage(nouveau_pv):
	pv_bar.value = nouveau_pv
