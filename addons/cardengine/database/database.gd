tool
extends Reference
class_name CardDatabase

var id    : String = ""
var name  : String = ""

var _cards: Dictionary = {}

func _init(id: String, name: String):
	self.id     = id
	self.name   = name

func cards() -> Dictionary:
	return _cards

func add_card(card: CardData) -> void:
	_cards[card.id] = card

func card_exists(id: String) -> bool:
	return _cards.has(id)

func get_card(id: String) -> CardData:
	if _cards.has(id):
		return _cards[id]
	else:
		return null

func remove_card(id: String) -> void:
	_cards.erase(id)

func exec_query(store: AbstractStore, query: Query) -> void:
	for id in _cards:
		var card = _cards[id]
		if query._match(card):
			store.add_card(card)
