extends Node2D

const COINS_PATH := "res://Saves/coins.save"
var coins: int = 0


func _ready() -> void:
	_load_coins()
	for i in range(1, 6):
		var node_name = "Item" + str(i)
		var btn = get_node(node_name) as Button
		
		if btn:
			# Successfully found the button from the scene!
			print("Loaded: ", btn.name)
			
			# Use a lambda to pass both the index 'i' and the button reference 'btn'
			btn.pressed.connect(func(): _on_button_pressed(i, btn))
		else:
			print("Warning: Could not find node named ", node_name)


func _load_coins() -> void:
	if not FileAccess.file_exists(COINS_PATH):
		return
	var f := FileAccess.open(COINS_PATH, FileAccess.READ)
	if f:
		coins = int(f.get_as_text().strip_edges())


func _save_coins() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://Saves"))
	var f := FileAccess.open(COINS_PATH, FileAccess.WRITE)
	if f:
		f.store_string(str(coins))


func _on_button_pressed(button_id: int, clicked_button: Button) -> void:
	print("Clicked button: Item", button_id)
	
	# Fetch the child "Price" label at the exact moment of the click
	var label = clicked_button.get_node_or_null("Price") as Label
	
	if label:
		print("Price label text: ", label.text)
	else:
		print("Warning: Could not find a 'Price' child node on ", clicked_button.name)
	check_if_buyable((label.text).to_int())
	

func check_if_buyable(price: int):
	if price <= coins:
		print("Bought")
		coins -= price
		_save_coins()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
