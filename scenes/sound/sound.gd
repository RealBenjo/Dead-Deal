extends Area2D


var loudness: int = 10

func _ready() -> void:
	$CollisionShape2D.shape.radius = loudness


# premade signals

# tells the enemy the sound position
func _on_body_entered(body: Node2D) -> void:
	body.sound_position = position
	body.sound_heard = true

# just deletes the sound after short delay
func _on_destroy_sound_timeout() -> void:
	queue_free()
