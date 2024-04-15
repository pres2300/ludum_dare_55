extends Node

@export var max_level_width : int = 5
@export var max_level_height : int = 5
@export var min_level_width : int = 2
@export var min_level_height : int = 2

@export var exit_chunk_scene : PackedScene
@export var spawn_chunk_scene : PackedScene
@export var basic_chunk_scene : PackedScene
@export var summoning_item_scene: PackedScene
@export var player_scene : PackedScene
@export var pistol : PackedScene
@export var enemy_scene : PackedScene
@export var boss_scene : PackedScene
@export var game_over_scene : PackedScene
@export var health_item_scene : PackedScene

@onready var canvas_layer = $CanvasLayer
@onready var hud = $CanvasLayer/HUD

@onready var summoning_items = $SummoningItems
@onready var enemies = $Enemies
@onready var level_chunks = $LevelChunks
@onready var items = $Items

const required_summoning_items : int = 5
const num_summoning_item_spawns : int = 5
var num_enemy_spawns : int = 2
var placed_summoning_items : int = 0

var summoning_circle = null
var player = null

# Level stats
var current_level : int = 0

func spawn_boss():
	var boss = boss_scene.instantiate()
	enemies.add_child(boss)
	boss.set_target(player)
	boss.global_position = summoning_circle.boss_spawn_location.global_position
	boss.boss_dead.connect(_boss_dead)

func boss_dead(item_position):
	summoning_circle.add_portal()
	summoning_circle.portal.next_level.connect(_next_level)
	spawn_health_item(item_position, 20)

func spawn_enemies(level : int, spawn_max_position : Vector2):
	# Add randomly placed enemies
	for i in range(num_enemy_spawns*level):
		var enemy = enemy_scene.instantiate()
		enemies.add_child(enemy)
		var random_pos = Vector2(randi_range(0, spawn_max_position.x), randi_range(0, spawn_max_position.y))
		enemy.global_position = random_pos
		enemy.set_target(player)
		enemy.enemy_died.connect(_enemy_dead)

func spawn_health_item(item_position, heal_amount=null):
	var health_item = health_item_scene.instantiate()
	items.add_child(health_item)
	if heal_amount != null:
		health_item.heal_amount = heal_amount
	health_item.global_position = item_position

func next_level():
	current_level += 1

	# Remove old level chunks
	for chunk in level_chunks.get_children():
		chunk.queue_free()

	# Remove old enemies
	for enemy in enemies.get_children():
		enemy.queue_free()

	# Remove old summoning items
	for item in summoning_items.get_children():
		item.queue_free()

	# Remove old items
	for item in items.get_children():
		item.queue_free()

	# Build the level
	var level_width = randi_range(min_level_width, max_level_width)
	var level_height = randi_range(min_level_height, max_level_height)
	var spawn_chunk = randi_range(0, (level_width*level_height)-1)
	var exit_chunk = spawn_chunk
	while exit_chunk == spawn_chunk:
		exit_chunk = randi_range(0, (level_width*level_height)-1)

	print("Level height: ", level_height)
	print("Level width: ", level_width)
	print("Spawn chunk: ", spawn_chunk)
	print("Exit chunk: ", exit_chunk)

	var current_chunk = 0
	var current_chunk_position : Vector2 = Vector2.ZERO
	var player_spawn_position : Vector2 = Vector2.ZERO
	var spawn_max_position : Vector2 = Vector2(1920*level_width, 1080*(level_height))
	for i in range(level_width):
		for j in range(level_height):

			var add_chunk = null
			if current_chunk == spawn_chunk:
				add_chunk = spawn_chunk_scene.instantiate()
				level_chunks.add_child(add_chunk)
				current_chunk_position.x = i*add_chunk.bg.texture.get_width()
				current_chunk_position.y = j*add_chunk.bg.texture.get_height()
				add_chunk.position = current_chunk_position
				player_spawn_position = add_chunk.player_spawn_point.global_position
			elif current_chunk == exit_chunk:
				add_chunk = exit_chunk_scene.instantiate()
				level_chunks.add_child(add_chunk)
				current_chunk_position.x = i*add_chunk.bg.texture.get_width()
				current_chunk_position.y = j*add_chunk.bg.texture.get_height()
				add_chunk.position = current_chunk_position
				summoning_circle = add_chunk.summoning_circle
				summoning_circle.spawn_boss.connect(_spawn_boss)
			else:
				add_chunk = basic_chunk_scene.instantiate()
				level_chunks.add_child(add_chunk)
				current_chunk_position.x = i*add_chunk.bg.texture.get_width()
				current_chunk_position.y = j*add_chunk.bg.texture.get_height()
				add_chunk.position = current_chunk_position

			current_chunk += 1

	# Add the player
	if player == null:
		player = player_scene.instantiate()
		add_child(player)
		player.summoning_item_collected.connect(_summoning_item_collected)
		player.player_health_changed.connect(_player_health_changed)
		player.player_died.connect(_game_over)
		player.add_weapon(pistol)
		hud.set_player_health(player.health)
	player.global_position = player_spawn_position
	player.set_camera_limit(0, 1080*level_height, 0, 1920*level_width)
	player.current_summoning_items = 0

	hud.set_level_number(current_level)
	hud.reset_summon_items_collected()

	# Add rondomly placed summoning items
	for i in range(num_summoning_item_spawns):
		var summoning_item = summoning_item_scene.instantiate()
		summoning_items.add_child(summoning_item)
		var random_pos = Vector2(randi_range(0, spawn_max_position.x), randi_range(0, spawn_max_position.y))
		summoning_item.global_position = random_pos

	spawn_enemies(current_level, spawn_max_position)

func _game_over():
	var game_over = game_over_scene.instantiate()
	canvas_layer.add_child(game_over)
	game_over.try_again.connect(_restart)
	game_over.main_menu.connect(_main_menu)

func _restart():
	current_level = 0
	call_deferred("next_level")
	player.queue_free()
	player = null

func _main_menu():
	get_tree().reload_current_scene()

func _summoning_item_collected():
	hud.increment_summon_items_collected()

func _player_health_changed(health):
	hud.set_player_health(health)

func _ready():
	$TitleScreen.start.connect(_start_game)

func _start_game():
	hud.show()
	$TitleScreen.queue_free()
	call_deferred("next_level")

func _next_level():
	call_deferred("next_level")

func _spawn_boss():
	call_deferred("spawn_boss")

func _boss_dead(item_position):
	call_deferred("boss_dead", item_position)

func _enemy_dead(item_position):
	call_deferred("spawn_health_item", item_position)
