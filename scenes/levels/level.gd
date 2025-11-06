extends Node2D
class_name LevelParent


@onready var player: CharacterBody2D = $Player
@onready var bullet_scene: PackedScene = preload("res://scenes/player/bullet.tscn")
@onready var sound_scene: PackedScene = preload("res://scenes/sound/sound.tscn")
@onready var grenade_scene: PackedScene # TODO: actually implement this
@onready var item_scene: PackedScene # TODO: actually implement this

var bullet
var sound

func _ready() -> void:
	pass


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
