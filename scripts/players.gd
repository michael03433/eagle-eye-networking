extends CharacterBody3D

@onready var camera: Camera3D = $Camera3D

const SPEED: float = 5.0
var gravity: float = ProjectSettings.get_setting(
    "physics/3d/default_gravity"
)


func _enter_tree() -> void:
	set_multiplayer_authority(int(name))


func _ready() -> void:
	camera.current = is_multiplayer_authority()

	print(
		"Player: ", name,
		" | Authority: ", get_multiplayer_authority(),
		" | My Peer ID: ", multiplayer.get_unique_id()
	)


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	var input_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
        "move_backward"
	)

	var _direction := (
		transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	).normalized()


	velocity.x = input_dir.x * SPEED
	velocity.z = input_dir.y * SPEED

	move_and_slide()
