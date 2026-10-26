class_name PoseLibrary
## Poses del cuerpo de tinta. Ángulos en grados por articulación.
## Brazos y piernas cuelgan hacia abajo: ángulo negativo = hacia delante.
## Torso y cabeza apuntan hacia arriba: ángulo positivo = inclinado hacia delante.
## root_y: desplazamiento vertical del cuerpo (positivo = agachado).

const CHANNELS: Array[StringName] = [&"root_y", &"chest", &"head", &"arm_f", &"arm_b", &"leg_f", &"leg_b"]

const POSES := {
	&"idle": {&"root_y": 0.0, &"chest": 2.0, &"head": 0.0, &"arm_f": -8.0, &"arm_b": 10.0, &"leg_f": -4.0, &"leg_b": 6.0},
	&"run_a": {&"root_y": -3.0, &"chest": 12.0, &"head": -6.0, &"arm_f": 35.0, &"arm_b": -35.0, &"leg_f": -42.0, &"leg_b": 32.0},
	&"run_b": {&"root_y": 1.0, &"chest": 12.0, &"head": -6.0, &"arm_f": -35.0, &"arm_b": 35.0, &"leg_f": 32.0, &"leg_b": -42.0},
	&"jump_up": {&"root_y": 0.0, &"chest": 6.0, &"head": -6.0, &"arm_f": 30.0, &"arm_b": 45.0, &"leg_f": -50.0, &"leg_b": 12.0},
	&"apex": {&"root_y": 0.0, &"chest": 4.0, &"head": 0.0, &"arm_f": -60.0, &"arm_b": -40.0, &"leg_f": -32.0, &"leg_b": -8.0},
	&"fall": {&"root_y": 0.0, &"chest": -4.0, &"head": 8.0, &"arm_f": -120.0, &"arm_b": -100.0, &"leg_f": -10.0, &"leg_b": 16.0},
	&"land": {&"root_y": 6.0, &"chest": 20.0, &"head": -10.0, &"arm_f": -20.0, &"arm_b": 20.0, &"leg_f": -35.0, &"leg_b": 35.0},
	&"wall": {&"root_y": 0.0, &"chest": -8.0, &"head": -12.0, &"arm_f": -40.0, &"arm_b": 150.0, &"leg_f": -20.0, &"leg_b": 24.0},
	&"dash": {&"root_y": -4.0, &"chest": 38.0, &"head": -22.0, &"arm_f": 70.0, &"arm_b": 85.0, &"leg_f": 40.0, &"leg_b": 62.0},
	&"attack_side_windup": {&"root_y": 2.0, &"chest": -14.0, &"head": 2.0, &"arm_f": 150.0, &"arm_b": 20.0, &"leg_f": -22.0, &"leg_b": 22.0},
	&"attack_side_strike": {&"root_y": 2.0, &"chest": 24.0, &"head": -8.0, &"arm_f": -95.0, &"arm_b": 45.0, &"leg_f": -32.0, &"leg_b": 32.0},
	&"attack_up_windup": {&"root_y": 3.0, &"chest": 10.0, &"head": 8.0, &"arm_f": 20.0, &"arm_b": 30.0, &"leg_f": -18.0, &"leg_b": 18.0},
	&"attack_up": {&"root_y": -2.0, &"chest": -12.0, &"head": -22.0, &"arm_f": -175.0, &"arm_b": 30.0, &"leg_f": -10.0, &"leg_b": 12.0},
	&"attack_down_windup": {&"root_y": 0.0, &"chest": -10.0, &"head": -8.0, &"arm_f": -150.0, &"arm_b": -40.0, &"leg_f": -40.0, &"leg_b": -20.0},
	&"attack_down": {&"root_y": 0.0, &"chest": 18.0, &"head": 16.0, &"arm_f": -8.0, &"arm_b": -60.0, &"leg_f": -62.0, &"leg_b": -30.0},
	&"heal": {&"root_y": 14.0, &"chest": 32.0, &"head": 26.0, &"arm_f": -40.0, &"arm_b": -44.0, &"leg_f": -55.0, &"leg_b": 55.0},
	&"puddle": {&"root_y": 0.0, &"chest": 0.0, &"head": 0.0, &"arm_f": 0.0, &"arm_b": 0.0, &"leg_f": 0.0, &"leg_b": 0.0},
	&"hurt": {&"root_y": 0.0, &"chest": -26.0, &"head": -26.0, &"arm_f": -100.0, &"arm_b": -125.0, &"leg_f": 22.0, &"leg_b": 32.0},
	&"dead": {&"root_y": 18.0, &"chest": 62.0, &"head": 40.0, &"arm_f": 22.0, &"arm_b": 18.0, &"leg_f": -72.0, &"leg_b": 52.0},
}

## Duración de la anticipación del ataque (coincide con player/states/attack.gd).
const ATTACK_WINDUP := 0.05


## Elige la pose según el estado del jugador.
static func pose_name_for(state: StringName, vel_y: float, attack_dir: StringName, attack_t: float) -> StringName:
	match state:
		&"idle":
			return &"idle"
		&"run":
			return &"run_a"
		&"jump":
			return &"jump_up" if vel_y < -250.0 else &"apex"
		&"fall":
			return &"apex" if vel_y < 250.0 else &"fall"
		&"wall_slide":
			return &"wall"
		&"dash":
			return &"dash"
		&"attack":
			var windup := attack_t < ATTACK_WINDUP
			match attack_dir:
				&"up":
					return &"attack_up_windup" if windup else &"attack_up"
				&"down":
					return &"attack_down_windup" if windup else &"attack_down"
				_:
					return &"attack_side_windup" if windup else &"attack_side_strike"
		&"heal":
			return &"heal"
		&"puddle":
			return &"puddle"
		&"hurt":
			return &"hurt"
		&"dead":
			return &"dead"
	return &"idle"
