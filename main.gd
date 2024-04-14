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

@onready var hud = $CanvasLayer/HUD

const required_summoning_items : int = 5
const num_summoning_item_spawns : int = 5
const num_enemy_spawns : int = 2
var placed_summoning_items : int = 0

var summoning_circle = null
var player = null

# Level stats
var current_level : int = 1

func spawn_boss():
	var boss = boss_scene.instantiate()
	add_child(boss)
	boss.set_target(player)
	boss.global_position = summoning_circle.boss_spawn_location.global_position

func _summoning_item_collected():
	hud.increment_summon_items_collected()

func _player_health_changed(health):
	hud.set_player_health(health)

func _ready():
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
	var item_spawn_max_position : Vector2 = Vector2(1920*level_width, 1080*(level_height))
	for i in range(level_width):
		for j in range(level_height):

			var add_chunk = null
			if current_chunk == spawn_chunk:
				add_chunk = spawn_chunk_scene.instantiate()
				add_child(add_chunk)
				current_chunk_position.x = i*add_chunk.bg.texture.get_width()
				current_chunk_position.y = j*add_chunk.bg.texture.get_height()
				add_chunk.position = current_chunk_position
				player_spawn_position = add_chunk.player_spawn_point.global_position
			elif current_chunk == exit_chunk:
				add_chunk = exit_chunk_scene.instantiate()
				add_child(add_chunk)
				current_chunk_position.x = i*add_chunk.bg.texture.get_width()
				current_chunk_position.y = j*add_chunk.bg.texture.get_height()
				add_chunk.position = current_chunk_position
				summoning_circle = add_chunk.summoning_circle
				summoning_circle.spawn_boss.connect(_spawn_boss)
			else:
				add_chunk = basic_chunk_scene.instantiate()
				add_child(add_chunk)
				current_chunk_position.x = i*add_chunk.bg.texture.get_width()
				current_chunk_position.y = j*add_chunk.bg.texture.get_height()
				add_chunk.position = current_chunk_position

			print("current_chunk_position: ", current_chunk_position, "current_chunk: ", current_chunk)

			current_chunk += 1

	# Add the player
	player = player_scene.instantiate()
	add_child(player)
	player.global_position = player_spawn_position
	player.add_weapon(pistol)
	player.set_camera_limit(0, 1080*level_height, 0, 1920*level_width)
	player.summoning_item_collected.connect(_summoning_item_collected)
	player.player_health_changed.connect(_player_health_changed)
	hud.set_player_health(player.health)

	# Add rondomly placed summoning items
	for i in range(num_summoning_item_spawns):
		var summoning_item = summoning_item_scene.instantiate()
		add_child(summoning_item)
		var random_pos = Vector2(randi_range(0, item_spawn_max_position.x), randi_range(0, item_spawn_max_position.y))
		summoning_item.global_position = random_pos

	# Add randomly placed enemies
	for i in range(num_enemy_spawns):
		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		var random_pos = Vector2(randi_range(0, item_spawn_max_position.x), randi_range(0, item_spawn_max_position.y))
		enemy.global_position = random_pos
		enemy.set_target(player)

func _spawn_boss():
	call_deferred("spawn_boss")
