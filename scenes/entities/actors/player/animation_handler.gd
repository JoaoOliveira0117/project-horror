extends Node

var player: CharacterBody3D
var p_camera: Camera3D
var anim: AnimationPlayer

var hvel: Vector3

func _physics_process(_delta):
	if not player or not anim:
		return
		
	hvel = player.hvel
	handle_bobbing_speed()
	
func handle_bobbing_speed():
	if not player.is_on_floor() or hvel.length() < 0.5:
		anim.pause()
		
	var speed = (hvel.length() / player.MAX_SPEED)
	anim.play("head_bobb")
	anim.speed_scale = speed
