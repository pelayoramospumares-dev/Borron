class_name MovementMath
## Fórmulas de movimiento.


static func jump_velocity(height: float, apex: float) -> float:
	return -2.0 * height / apex


static func gravity(height: float, apex: float) -> float:
	return 2.0 * height / (apex * apex)


static func approach(v: float, target: float, rate: float, delta: float) -> float:
	return move_toward(v, target, rate * delta)
