package main

Light :: struct {
	direction: Vec3,
	strength:  f32,
}

make_light :: proc(dir: Vec3, strength: f32) -> Light {
	return {
		direction =  normalize(dir),
		strength = strength
	}
}

