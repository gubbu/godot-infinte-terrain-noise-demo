extends Spatial



export (PackedScene) var physics_ball


onready var bullet_origin: Spatial = $GodmodePlayer/Camera

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_released("left_mouse_button"):
		print("shooting")
		var instance: RigidBody = physics_ball.instance()
		self.add_child(instance)
		print(bullet_origin)
		instance.global_transform.origin = bullet_origin.global_transform.origin
		var back_direction = bullet_origin.global_transform.basis.z
		instance.add_central_force(back_direction * -5000)
