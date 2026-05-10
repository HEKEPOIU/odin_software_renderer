package main

import "core:math"


Vec2 :: [2]f32
Vec3 :: [3]f32
Vec4 :: [4]f32

normalize :: proc(v: Vec3) -> Vec3 {
	length := math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2])
	if length == 0 do return 0

	return v / length
}

cross :: proc(v1, v2: Vec3) -> Vec3 {
	return {
		v1[1] * v2[2] - v1[2] * v2[1],
		-(v1[0] * v2[2] - v1[2] * v2[0]),
		v1[0] * v2[1] - v1[1] * v2[0],
	}
}

cross_2d :: proc(v1, v2: Vec2) -> f32 {
	return v1.x * v2.y - v1.y * v2.x
	// equal to:
	// return cross(Vec3{v1.x,v1.y, 0}, Vec3{v2.x,v2.y, 0} ).z
	// that why it called cross 2d, since cross only define in 3d
	// and it means sign size of parallelogram
}

dot_v3 :: proc(v1, v2: Vec3) -> f32 {
	return v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2]
}

dot_v4 :: proc(v1, v2: Vec4) -> f32 {
	return v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2] + v1[3] * v2[3]
}

floor_xy :: proc(v: ^Vec3) {
	v.x, v.y  = math.floor(v.x), math.floor(v.y)
}

dot :: proc{
    dot_v3,
    dot_v4
}

