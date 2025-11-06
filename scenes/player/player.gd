extends CharacterBody2D


signal bullet_signal(pos: Vector2, direction: Vector2)
signal sound_signal(pos: Vector2, loudness: float)

const BULLET_LOUDNESS: float = 2000.0

var direction: Vector2
var speed: int = 400
var weapon_zoom: float = 2.5
var can_shoot: bool = true

@onready var bullet: PackedScene = preload("res://scenes/player/bullet.tscn")

var player_direction

func _process(_delta: float) -> void:
	# input
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed # direction is ALWAYS A VECTOR
	move_and_slide()
	Globals.player_pos = global_position
	
	# rotate player
	look_at(get_global_mouse_position())
	
	# ADS zoom type shit
	if Input.is_action_pressed("secondary_action"):
		weapon_zoom = 2.5
	else:
		weapon_zoom = 10.0
	$Camera2D.offset = (get_global_mouse_position() - position) / weapon_zoom
	
	# get player direction for bullet placement and rotation
	player_direction = (get_global_mouse_position() - position).normalized()
	
	# SHOOTING
	if Input.is_action_pressed("primary_action") and can_shoot and Globals.ammo > 0:
		can_shoot = false
		Globals.ammo -= 1
		$ShootTimer.start()
		
		# emit the corresponding signals
		bullet_signal.emit($MuzzleEnd.global_position, player_direction)
		sound_signal.emit($MuzzleEnd.global_position, BULLET_LOUDNESS)


# premade signals

# timing between shots
func _on_shoot_timer_timeout() -> void:
	can_shoot = true
