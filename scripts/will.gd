extends CharacterBody3D

@export var step_size: float = 1.0 
@export var move_speed: float = 0.25 
@export var hold_time_to_walk: float = 0.15 

var is_moving = false
var last_direction = Vector3.FORWARD 
var time_holding = 0.0
var active_dir = Vector3.ZERO

@onready var ray = $RayCast3D
@onready var ray_suelo = $RayCastSuelo # El raycast apuntando hacia abajo
@onready var anim = $AnimatedSprite3D

# Guarda la posición inicial para reiniciar si cae al vacío
@onready var respawn_position: Vector3 = global_position

func _ready():
	anim.play("idle")

func _physics_process(delta):
	if is_moving:
		return

	var dir = Vector3.ZERO
	
	var right = Input.is_action_pressed("derecha")
	var left = Input.is_action_pressed("izquierda")
	var down = Input.is_action_pressed("abajo")
	var up = Input.is_action_pressed("arriba")

	if right and not left:
		dir = Vector3.RIGHT
	elif left and not right:
		dir = Vector3.LEFT

	if down and not up:
		if dir == Vector3.ZERO:
			dir = Vector3.BACK 
	elif up and not down:
		if dir == Vector3.ZERO:
			dir = Vector3.FORWARD 

	if dir != Vector3.ZERO:
		if dir != last_direction:
			last_direction = dir
			play_idle_animation(dir)
			time_holding = 0.0
			active_dir = dir
			return 

		if dir == active_dir:
			time_holding += delta
			if time_holding >= hold_time_to_walk:
				ray.target_position = dir * step_size
				ray.force_raycast_update()
				
				if ray.is_colliding():
					play_idle_animation(dir)
				else:
					move_to(dir)
		else:
			active_dir = dir
			time_holding = 0.0
	else:
		time_holding = 0.0
		active_dir = Vector3.ZERO
		play_idle_animation(last_direction)

func move_to(dir: Vector3):
	is_moving = true
	play_walk_animation(dir)
	
	var target_pos = global_position + (dir * step_size)

	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, move_speed)
	
	tween.tween_callback(func():
		# Al terminar el paso, revisamos si hay suelo debajo
		ray_suelo.force_raycast_update()
		if not ray_suelo.is_colliding():
			morir_por_caida()
		else:
			is_moving = false
	)

func morir_por_caida():
	# Animación o efecto de caída y reseteo
	print("¡Caíste al vacío!")
	
	var tween_caida = create_tween()
	# Lo hundimos un poco hacia abajo
	tween_caida.tween_property(self, "global_position", global_position + Vector3(0, -3, 0), 0.5)
	
	tween_caida.tween_callback(func():
		# Regresar a la posición segura y limpiar estado
		global_position = respawn_position
		is_moving = false
		anim.play("idle")
	)

func play_walk_animation(dir: Vector3):
	if dir == Vector3.RIGHT:
		anim.flip_h = false
		anim.play("walk_side")
	elif dir == Vector3.LEFT:
		anim.flip_h = true
		anim.play("walk_side")
	elif dir == Vector3.BACK:
		anim.play("walk")
	elif dir == Vector3.FORWARD:
		anim.play("walk_back")

func play_idle_animation(dir: Vector3):
	if dir == Vector3.RIGHT:
		anim.flip_h = false
		anim.play("idle_side")
	elif dir == Vector3.LEFT:
		anim.flip_h = true
		anim.play("idle_side")
	elif dir == Vector3.BACK:
		anim.play("idle")
	elif dir == Vector3.FORWARD:
		anim.play("idle_back")
