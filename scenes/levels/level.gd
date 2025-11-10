extends Node2D
class_name LevelParent


# scene vars
@onready var player: CharacterBody2D = $Player
@onready var zombie_scene: PackedScene = preload("res://scenes/enemies/zombie.tscn")
@onready var bullet_scene: PackedScene = preload("res://scenes/player/bullet.tscn")
@onready var sound_scene: PackedScene = preload("res://scenes/sound/sound.tscn")
@onready var grenade_scene: PackedScene # TODO: actually implement this
@onready var item_scene: PackedScene # TODO: actually implement this

# patrol vars
@onready var patrols = get_node("/root/Level/Patrols").get_children() ##array of ALL patrol nodes
@onready var enemies = get_node("/root/Level/Enemies").get_children() ##array of ALL enemy nodes

var zombie

func _ready() -> void:
	for enemy in enemies:
		zombie = zombie_scene.instantiate()
		enemy.add_child(zombie)
	

var bullet
var sound

func get_zombie() -> void:
	pass

##returns array of all marker positions in a patrol
func get_patrol(index: int) -> Array:
	var patrol_positions: Array
	var patrol = patrols.get(index)
	for j in patrol.get_child_count():
		patrol_positions.append(patrol.get_child(j).position)
	
	return patrol_positions

func create_bullet(pos: Vector2, direction: Vector2) -> void:
	bullet = bullet_scene.instantiate() as Node2D
	
	bullet.position = pos
	bullet.rotation = direction.angle()
	bullet.direction = direction
	
	$Projectiles.add_child(bullet)

func create_sound(pos: Vector2, loudness: float) -> void:
	sound = sound_scene.instantiate() as Area2D
	
	sound.position = pos
	sound.loudness = loudness
	
	$Sounds.add_child(sound)

# custom signals
func _on_player_bullet_signal(pos: Vector2, direction: Vector2) -> void:
	create_bullet(pos, direction)

func _on_player_sound_signal(pos: Vector2, loudness: float) -> void:
	create_sound(pos, loudness)
