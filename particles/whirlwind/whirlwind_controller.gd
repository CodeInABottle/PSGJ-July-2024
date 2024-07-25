extends BaseAttack

@onready var particles: CPUParticles2D = %Particles
@onready var destination_marker: Marker2D = %DestinationMarker

func on_start() -> void:
	die_timer.start()
	var move_tween: Tween =  create_tween()
	move_tween.tween_property(particles, "position", destination_marker.get_position(), die_timer.get_wait_time())
