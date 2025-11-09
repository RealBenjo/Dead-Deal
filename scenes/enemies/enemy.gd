extends CharacterBody2D
class_name EnemyWalking


# node vars
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var vision: RayCast2D = $Vision

# vision vars
@export_range(0, 360, 0.1, "degrees") var fov: float = 90.0
@export var default_vision_length: int = 300
var vision_length: Vector2 = Vector2(default_vision_length, 0)

# basic functionality vars
@export var speed: float = 100.0 ##player run speed is 400 for reference
@export var health: int = 100 ##normal walker zombie has 100 health for reference
@export var damage: int = 10 ##player health is 100 for reference

#TODO: add awareness with the description down below (the shorter the distance, the faster the awareness buildup)
##1000 means that if the player is standing still, it will take 1s for the zombie to spot you at the distance of 1000px 
@export var max_awareness: float = 1000.0 
var awareness: float = 0.0

#state vars
var player_seen: bool = false ##if player is seen, this is true
var sound_heard: bool = false ##if any sound is heard, this is true

#pathfinding vars
var last_interest_pos: Vector2 ##the position where the enemy wants to go to
var sound_position: Vector2 ##this position is given by the sound scene

#patrol vars
@onready var patrol_node = get_node("../../../Patrols/Patrol1")
@onready var patrol_positions = patrol_node.get_children()


func _ready() -> void:
	vision.target_position = vision_length
	print(patrol_positions)

func _physics_process(_delta):
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
	
	# both in global space
	var next_path_pos = nav.get_next_path_position()
	var dir = (next_path_pos - global_position).normalized()
	
	switch_state(next_path_pos, dir)
	
	# handles enemy vision cone
	var player_direction = (vision.get_parent().to_local(Globals.player_pos) - vision.position).angle() # direction in RAD
	if rad_to_deg(player_direction) > fov/2: # checks if player on right side of enemy
		player_direction = deg_to_rad(fov/2)
	elif rad_to_deg(player_direction) < -1 * fov/2: # checks if player on left side of enemy
		player_direction = deg_to_rad(-1 * fov/2)
	
	vision.rotation = player_direction # places raycast to correct vision cone position
	
	if nav.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	
	
	# move enemy, whilst trying to avoid others
	var desired_velocity = dir * speed
	nav.set_velocity(desired_velocity)
	velocity = nav.get_velocity()
	move_and_slide()

## what the enemy does when player is seen, when sound is heard etc.
func switch_state(targeted_pos: Vector2, path_direction: Vector2) -> void:
	# handles enemy vision length and pathfinding to a position 
	if player_seen:
		look_at(Globals.player_pos)
		last_interest_pos = Globals.player_pos
		
		vision_length = Vector2.RIGHT * 3000
		vision.target_position = vision_length
		
	elif sound_heard:
		sound_heard = false
		
		# makes the enemy go to roughly where the sound was heard
		var displaceX = randi_range(-500, 500)
		var displaceY = randi_range(-500, 500)
		last_interest_pos = sound_position + Vector2(displaceX, displaceY)
		
	else:
		# smooth rotation towards target
		if (targeted_pos - global_position).length() > 4.0:
			var target_angle = path_direction.angle()
			rotation = lerp_angle(rotation, target_angle, 0.15)
		
		vision_length = Vector2(default_vision_length, 0)
		vision.target_position = vision_length
		velocity = Vector2.ZERO
		# TODO: add idle animation or idle movement

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
