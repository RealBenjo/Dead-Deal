extends CharacterBody2D
class_name EnemyWalking


@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var vision: RayCast2D = $Vision

# vision vars
@export_range(0, 360, 0.1, "degrees") var fov: float = 90.0
@export var default_vision_length: int = 300
var vision_length: Vector2 = Vector2(default_vision_length, 0)

# functionality vars
@export var speed: float = 100.0
@export var health: int = 100
@export var damage: int = 10

var player_seen: bool = false
var sound_heard: bool = false

var last_interest_pos: Vector2
var sound_position: Vector2

func _ready() -> void:
	vision.target_position = vision_length

func _physics_process(_delta):
	# handles enemy vision cone
	var player_direction = (vision.get_parent().to_local(Globals.player_pos) - vision.position).angle() # direction in RAD
	if rad_to_deg(player_direction) > fov/2: # right side of enemy
		player_direction = deg_to_rad(fov/2)
	elif rad_to_deg(player_direction) < -1 * fov/2: # left side of enemy
		player_direction = deg_to_rad(-1 * fov/2)
	
	vision.rotation = player_direction # places raycast to correct vision cone position
	
	# handles enemy vision detection
	if vision.is_colliding():
		var collider = vision.get_collider()
		if collider.is_in_group("Player"):
			player_seen = true
			sound_heard = false
		else:
			player_seen = false
	else:
		player_seen = false
	
	# handles enemy pathfinding to a position
	if player_seen:
		last_interest_pos = Globals.player_pos
		
		vision_length = Vector2.RIGHT * 3000
		vision.target_position = vision_length
	elif sound_heard:
		sound_heard = false
		var displacex = randi_range(-500, 500)
		var displacey = randi_range(-500, 500)
		last_interest_pos = sound_position + Vector2(displacex, displacey)
	else:
		vision_length = Vector2(default_vision_length, 0)
		vision.target_position = vision_length
		velocity = Vector2.ZERO
		# TODO: add idle animation or idle movement
	
	
	if nav.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	# both in global space
	var next_path_pos = nav.get_next_path_position()
	var dir = (next_path_pos - global_position).normalized()

	# smooth rotation towards target
	if (next_path_pos - global_position).length() > 4.0:
		var target_angle = dir.angle()
		rotation = lerp_angle(rotation, target_angle, 0.15)

	# move enemy
	velocity = dir * speed
	move_and_slide()
	


func make_path(interest_position: Vector2) -> void:
	nav.target_position = interest_position

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func die():
	#anim.play("die")
	queue_free()


# premade signals
