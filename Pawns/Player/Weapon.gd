extends Spatial

export var ads_position : Vector3
export var default_position : Vector3
export (float, 0, 1.0) var acceleration = 0.25

onready var current_position = default_position

func _ready():
	pass

func _process(delta):
	transform.origin = transform.origin.linear_interpolate(current_position, acceleration)

func view_default():
	current_position = default_position

func view_ads():
	current_position = ads_position
