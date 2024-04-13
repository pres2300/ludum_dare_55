extends Node2D

var items_dropped : int = 0

func get_summoning_items():
	return $SummoningItemSlots.get_children()

func _summoning_item_dropped():
	items_dropped += 1

	if items_dropped == 5:
		print("Do the summoning")

func _ready():
	for summon_item_slot in $SummoningItemSlots.get_children():
		summon_item_slot.selected.connect(_summoning_item_dropped)
