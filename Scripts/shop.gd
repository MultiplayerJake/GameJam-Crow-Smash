extends Node2D

const COINS_FILE := "coins.save"
const PRICE_FONT_SIZE := 35
const STATUS_FONT_SIZE := 23
var coins: int = 0

var owned_bats: Array[int] = []
var owned_crows: Array[int] = []
var equipped_bat: int = 0
var equipped_crow: int = 0

@onready var coins_label: Label = $CoinsLabel


func _ready() -> void:
	_load_coins()
	_load_skins()
	_update_coins_label()
	for i in range(1, 6):
		var node_name = "Item" + str(i)
		var btn = get_node(node_name) as Button
		
		if btn:
			# Successfully found the button from the scene!
			print("Loaded: ", btn.name)
			var price_label = btn.get_node_or_null("Price") as Label
			if price_label:
				btn.set_meta("price", int(price_label.text))
			
			var image = btn.get_node_or_null("Image") as TextureRect
			if image:
				var product: int = btn.get_meta("ProductID", 0)
				var kind: String = btn.get_meta("Kind", "")
				image.texture = SkinData.get_texture(kind, product)
			
			# Use a lambda to pass both the index 'i' and the button reference 'btn'
			btn.pressed.connect(func(): _on_button_pressed(i, btn))
			_update_item_status(btn)
		else:
			print("Warning: Could not find node named ", node_name)
	$Default.pressed.connect(_on_default_button_pressed)


func _load_coins() -> void:
	var path := SavePaths.file(COINS_FILE)
	if not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if f:
		coins = int(f.get_as_text().strip_edges())


func _load_skins() -> void:
	SkinData.load_skins()
	owned_bats = SkinData.owned_bats
	owned_crows = SkinData.owned_crows
	_sync_equipped()


func _sync_equipped() -> void:
	equipped_bat = SkinData.equipped_bat
	equipped_crow = SkinData.equipped_crow


func _equipped_number(kind: String) -> int:
	if kind == SkinData.KIND_BAT:
		return equipped_bat
	elif kind == SkinData.KIND_CROW:
		return equipped_crow
	return 0


func _save_coins() -> void:
	var f := FileAccess.open(SavePaths.file(COINS_FILE), FileAccess.WRITE)
	if f:
		f.store_string(str(coins))


func _update_coins_label() -> void:
	coins_label.text = "Coins: %d" % coins


func _update_item_status(btn: Button) -> void:
	var label := btn.get_node_or_null("Price") as Label
	if label == null:
		return
	var product: int = btn.get_meta("ProductID", 0)
	var kind: String = btn.get_meta("Kind", "")
	if SkinData.is_owned(kind, product):
		label.add_theme_font_size_override("font_size", STATUS_FONT_SIZE)
		if SkinData.is_equipped(kind, product):
			label.text = "EQUIPPED"
			label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.45))
		else:
			label.text = "OWNED"
			label.add_theme_color_override("font_color", Color(0.3, 0.65, 1.0))
	else:
		label.text = str(btn.get_meta("price", 0))
		label.add_theme_font_size_override("font_size", PRICE_FONT_SIZE)
		label.add_theme_color_override("font_color", Color(1, 1, 1, 1))


func _refresh_statuses() -> void:
	for i in range(1, 6):
		var btn = get_node_or_null("Item" + str(i)) as Button
		if btn:
			_update_item_status(btn)


func _on_button_pressed(button_id: int, clicked_button: Button) -> void:
	print("Clicked button: Item", button_id)
	
	# Fetch the child "Price" label at the exact moment of the click
	var label = clicked_button.get_node_or_null("Price") as Label
	
	if label == null:
		print("Warning: Could not find a 'Price' child node on ", clicked_button.name)
		return
	print("Price label text: ", label.text)
	var product: int = clicked_button.get_meta("ProductID", 0)
	var kind: String = clicked_button.get_meta("Kind", "")
	
	if product <= 0 or (kind != SkinData.KIND_BAT and kind != SkinData.KIND_CROW):
		print("Invalid item data (kind=", kind, ", product=", product, ")")
		return
	
	if SkinData.is_owned(kind, product):
		SkinData.equip_skin(kind, product)
		_sync_equipped()
		_refresh_statuses()
		print("Equipped ", kind, " skin ", product, " (active: ", _equipped_number(kind), ")")
		return

	var price: int = clicked_button.get_meta("price", 0)
	if check_if_buyable(price):
		SkinData.add_owned_skin(kind, product)
		SkinData.equip_skin(kind, product)
		_sync_equipped()
		_refresh_statuses()
		_update_coins_label()
		print("Equipped ", kind, " skin ", product, " (active: ", _equipped_number(kind), ")")
	else:
		print("Did not buy! insufficient funds!")
	


func check_if_buyable(price: int) -> bool:
	if price <= coins:
		print("Bought")
		coins -= price
		_save_coins()
		return true
	else:
		return false


func _on_default_button_pressed() -> void:
	SkinData.equip_skin(SkinData.KIND_BAT, 0)
	SkinData.equip_skin(SkinData.KIND_CROW, 0)
	_sync_equipped()
	_refresh_statuses()
	print("Reset to default skin")


# Called every frame. 'delta' is the time since the previous frame.
func _process(delta: float) -> void:
	pass
