extends Control

@onready var pv_bar = $PvBar
@onready var mana_bar = $ManaBar
@onready var terror_bar = $TerrorBar

func _ready():
	pv_bar.min_value = 0
	pv_bar.max_value = 100
	pv_bar.value = 80
	pv_bar.show_percentage = false

	mana_bar.min_value = 0
	mana_bar.max_value = 100
	mana_bar.value = 50
	mana_bar.show_percentage = false

	terror_bar.min_value = 0
	terror_bar.max_value = 100
	terror_bar.value = 30
	terror_bar.show_percentage = false
