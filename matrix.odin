package main

import "core:math"

Mat4x4 :: matrix[4, 4]f32


mat4_mul_vec3 :: proc(mat: Mat4x4, v: Vec3) -> Vec3 {
	return (mat * Vec4{v.x, v.y, v.z, 1}).xyz
}

make_translate_mat :: proc(x, y, z: f32) -> Mat4x4 {
	// odinfmt: disable
	return {
		1, 0, 0, x,
		0, 1, 0, y,
		0, 0, 1, z,
		0, 0, 0, 1
	}
	// odinfmt: enable
}

make_scale_mat :: proc(sx, sy, sz: f32) -> Mat4x4 {
	// odinfmt: disable
	return {
		sx, 0, 0, 0,
		0, sy, 0, 0,
		0, 0, sz, 0,
		0, 0,  0, 1
	}
	// odinfmt: enable
}

make_rotation_mat_degree :: proc(pitch, yaw, roll: f32) -> Mat4x4 {
	alpha := yaw * DEG_TO_RAD
	beta := pitch * DEG_TO_RAD
	gamma := roll * DEG_TO_RAD

	ca := math.cos(alpha)
	sa := math.sin(alpha)

	cb := math.cos(beta)
	sb := math.sin(beta)

	cg := math.cos(gamma)
	sg := math.sin(gamma)

	// this just came from YXZ rotation,
	// we can also 
	// rx_mat := rotation_mat_x(rx)
	// ry_mat := rotation_mat_y(ry)
	// rz_mat := rotation_mat_z(rz)
	// return mat4_mul_mat4(ry_mat,mat4_mul_mat4(rx_mat, rz_mat))
	// odinfmt: disable
	return Mat4x4 {
		ca * cb, ca * sb * sg - sa * cg, ca * sb * cg + sa * sg, 0.0,
		sa * cb, sa * sb * sg + ca * cg, sa * sb * cg - ca * sg, 0.0,
		-sb	, cb * sg		, cb * cg		, 0.0,
		0.0	, 0.0			, 0.0			, 1.0,
	}
	// odinfmt: enable
}


make_view_mat :: proc(eyes, target: Vec3) -> Mat4x4 {
	// in view space, we let -z become forward, this align to opengl/vulkan/metal etc.
	// and our global space z forward, x left, y up.
	forward := normalize(eyes - target)
	left := normalize(cross(Vec3{0, 1, 0}, forward))
	up := cross(forward, left)
	
	//odinfmt: disable
	return {
		left.x     , left.y    , left.z    , -dot(left, eyes)   ,
		up.x       , up.y      , up.z      , -dot(up, eyes)     ,
		forward.x  , forward.y , forward.z , -dot(forward, eyes),
		0          , 0         , 0         , 1                  ,
	}
	//odinfmt: enable
}

make_projection_mat :: proc(
	fov: f32,
	screen_width, screen_height: i32,
	near: f32,
	far: f32,
) -> Mat4x4 {
	f := 1.0 / math.tan_f32(fov * 0.5 * DEG_TO_RAD)
	aspect := f32(screen_width) / f32(screen_height)
	
	// odinfmt: disable
	// z_n = (A*z_p+B*1)/-z_p = -A + B/-z_p  << why divide z_p : require by x and y, and - are because our camara forward are -z
	// z_n in [0, 1] 
	// solve A and B
	return {
	        f / aspect	, 0.0	, 0.0				, 0.0,
		0.0		, -f	, 0.0				, 0.0,
        	0.0		, 0.0	, -far / (far - near)		,-1.0,
        	0.0		, 0.0	, -far * near / (far - near)	, 0.0,
	}
	// odinfmt: enable
}

