package main

import "core:math"
import "core:sort"
import rl "vendor:raylib"


is_backface :: proc(v1, v2, v3: Vec3) -> bool {
	eage1 := v2 - v1
	eage2 := v3 - v1
	normal := normalize(cross(eage1, eage2))
	// v in view space, that camera at [0,0,0]
	camera_to_v := normalize(v1)


	return dot(camera_to_v, normal) > 0
}

to_ndc :: proc(mat: Mat4x4, v: Vec3) -> Vec3 {
	clip := mat * Vec4{v.x, v.y, v.z, 1}
	ndc := clip.xyz / clip.w

	// why we use 1/w here?
	// it ok to use z/w for ztesting, it work well.
	// but it not correct when we trying to interperlate between two point.
	// clip.z in projection matrix are not liner.
	return Vec3{clip.x / clip.w, clip.y / clip.w, 1 / clip.w}
}

to_screen :: proc(ndc: Vec3) -> Vec3 {
	screen_x := ((ndc.x + 1) * 0.5) * SCREEN_WIDTH
	screen_y := ((ndc.y + 1) * 0.5) * SCREEN_HEIGHT
	return {screen_x, screen_y, ndc.z}
}

is_face_outside_frustum :: proc(ndc_p1, ndc_p2, ndc_p3: Vec3) -> bool {
	if ndc_p1.z > 1 && ndc_p2.z > 1 && ndc_p3.z > 1 do return true
	if ndc_p1.z < 0 && ndc_p2.z < 0 && ndc_p3.z < 0 do return true

	min_x := math.min(ndc_p1.x, ndc_p2.x, ndc_p3.x)
	min_y := math.min(ndc_p1.y, ndc_p2.y, ndc_p3.y)

	max_x := math.max(ndc_p1.x, ndc_p2.x, ndc_p3.x)
	max_y := math.max(ndc_p1.y, ndc_p2.y, ndc_p3.y)

	if max_x < -1 || min_x > 1 || max_y < -1 || min_y > 1 {
		return true
	}


	return false
}

draw_line :: proc(p1, p2: Vec3, color: rl.Color) {
	dx := p2.x - p1.x
	dy := p2.y - p1.y
	abs_dx := math.abs(dx)
	abs_dy := math.abs(dy)
	max_d := abs_dx >= abs_dy ? abs_dx : abs_dy

	inc_x := dx / max_d
	inc_y := dy / max_d

	x := p1.x
	y := p1.y

	for i := 0; i <= int(max_d); i += 1 {
		rl.DrawPixel(i32(x), i32(y), color)
		x += inc_x
		y += inc_y
	}
}

draw_wireframe :: proc(
	vertices: []Vec3,
	triangle: []Triangle,
	project_mat: Mat4x4,
	color: rl.Color,
	cull_backface: bool,
) {
	for &tri in triangle {
		v1 := vertices[tri[0]]
		v2 := vertices[tri[1]]
		v3 := vertices[tri[2]]
		if cull_backface && is_backface(v1, v2, v3) {
			continue
		}
		ndc_p1 := to_ndc(project_mat, v1)
		ndc_p2 := to_ndc(project_mat, v2)
		ndc_p3 := to_ndc(project_mat, v3)

		// fmt.printfln("{}, {}, {}", ndc_p1, ndc_p2, ndc_p3)
		if (is_face_outside_frustum(ndc_p1, ndc_p2, ndc_p3)) do continue

		p1 := to_screen(ndc_p1)
		p2 := to_screen(ndc_p2)
		p3 := to_screen(ndc_p3)

		draw_line(p1, p2, color)
		draw_line(p2, p3, color)
		draw_line(p3, p1, color)
	}
}

draw_unit :: proc(
	vertices: []Vec3,
	triangle: []Triangle,
	project_mat: Mat4x4,
	color: rl.Color,
	zbuffer: ^ZBuffer,
) {
	for &tri in triangle {
		v1 := vertices[tri[0]]
		v2 := vertices[tri[1]]
		v3 := vertices[tri[2]]
		if is_backface(v1, v2, v3) {
			continue
		}
		ndc_p1 := to_ndc(project_mat, v1)
		ndc_p2 := to_ndc(project_mat, v2)
		ndc_p3 := to_ndc(project_mat, v3)

		// fmt.printfln("{}, {}, {}", ndc_p1, ndc_p2, ndc_p3)
		if (is_face_outside_frustum(ndc_p1, ndc_p2, ndc_p3)) do continue

		p1 := to_screen(ndc_p1)
		p2 := to_screen(ndc_p2)
		p3 := to_screen(ndc_p3)

		draw_filled_triangle(p1, p2, p3, color, zbuffer)
	}
}

draw_flat_shaded :: proc(
	vertices: []Vec3,
	triangle: []Triangle,
	project_mat: Mat4x4,
	light: Light,
	color: rl.Color,
	zbuffer: ^ZBuffer,
	ambient: f32 = 0.2,
) {
	for &tri in triangle {
		v1 := vertices[tri[0]]
		v2 := vertices[tri[1]]
		v3 := vertices[tri[2]]

		normal := normalize(cross(v2 - v1, v3 - v1))
		// v in view space, that camera at [0,0,0]
		camera_to_v := normalize(v1)

		if dot(normal, camera_to_v) > 0 {
			continue
		}
		ndc_p1 := to_ndc(project_mat, v1)
		ndc_p2 := to_ndc(project_mat, v2)
		ndc_p3 := to_ndc(project_mat, v3)

		// fmt.printfln("{}, {}, {}", ndc_p1, ndc_p2, ndc_p3)
		if (is_face_outside_frustum(ndc_p1, ndc_p2, ndc_p3)) do continue

		p1 := to_screen(ndc_p1)
		p2 := to_screen(ndc_p2)
		p3 := to_screen(ndc_p3)

		intensity := math.clamp(dot(normal, light.direction), ambient, 1.0)
		shaded_color := rl.Color {
			u8(f32(color.r) * intensity),
			u8(f32(color.g) * intensity),
			u8(f32(color.b) * intensity),
			color.a,
		}

		draw_filled_triangle(p1, p2, p3, shaded_color, zbuffer)
	}
}

draw_textured_flat_shaded :: proc(
	vertices: []Vec3,
	triangle: []Triangle,
	uvs: []Vec2,
	light: Light,
	texture: Texture,
	zbuffer: ^ZBuffer,
	project_mat: Mat4x4,
	ambient: f32 = 0.2,
) {
	for &tri in triangle {
		v1 := vertices[tri[0]]
		v2 := vertices[tri[1]]
		v3 := vertices[tri[2]]

		normal := normalize(cross(v2 - v1, v3 - v1))
		// v in view space, that camera at [0,0,0]
		camera_to_v := normalize(v1)

		if dot(normal, camera_to_v) > 0 {
			continue
		}
		ndc_p1 := to_ndc(project_mat, v1)
		ndc_p2 := to_ndc(project_mat, v2)
		ndc_p3 := to_ndc(project_mat, v3)

		// fmt.printfln("{}, {}, {}", ndc_p1, ndc_p2, ndc_p3)
		if (is_face_outside_frustum(ndc_p1, ndc_p2, ndc_p3)) do continue

		p1 := to_screen(ndc_p1)
		p2 := to_screen(ndc_p2)
		p3 := to_screen(ndc_p3)

		intensity := math.clamp(dot(normal, light.direction), ambient, 1.0)

		draw_textured_triangle_flat_shaded(
			p1,
			p2,
			p3,
			uvs[tri[3]],
			uvs[tri[4]],
			uvs[tri[5]],
			texture,
			intensity,
			zbuffer,
		)
	}
}


draw_textured_triangle_flat_shaded :: proc(
	p1, p2, p3: Vec3,
	uv1, uv2, uv3: Vec2,
	texture: Texture,
	intensity: f32,
	zbuffer: ^ZBuffer,
) {
	Vertex_Zip :: struct {
		point: Vec3,
		uv:    Vec2,
	}
	zip: []Vertex_Zip = {{p1, uv1}, {p2, uv2}, {p3, uv3}}
	sort.quick_sort_proc(zip, proc(p1, p2: Vertex_Zip) -> int {
		return sort.compare_f32s(p1.point.y, p2.point.y)
	})
	p1, p2, p3 := zip[0].point, zip[1].point, zip[2].point
	uv1, uv2, uv3 := zip[0].uv, zip[1].uv, zip[2].uv

	floor_xy(&p1)
	floor_xy(&p2)
	floor_xy(&p3)

	if p2.y == p3.y {
		#force_inline fill_bottom(p1, p2, p3, uv1, uv2, uv3, texture, intensity, zbuffer)
	} else if p1.y == p2.y {
		#force_inline fill_up(p1, p2, p3, uv1, uv2, uv3, texture, intensity, zbuffer)
	} else {
		t := (p2.y - p1.y) / (p3.y - p1.y)
		p4 := Vec3{p1.x + t * (p3.x - p1.x), p2.y, 0}
		weights := barycentric_weights(p1.xy, p2.xy, p3.xy, p4.xy)
		z := (weights[0] * p1.z + weights[1] * p2.z + weights[2] * p3.z)

		p4.z = z
		// screen point interperlate  are not equal to 3d space interperlate
		// z = 1 / w
		// a/w * w = a
		uv4 :=
			((uv1 * p1.z) * weights[0] +
				(uv2 * p2.z) * weights[1] +
				(uv3 * p3.z) * weights[2]) *
			(1 / z)

		#force_inline fill_bottom(p1, p2, p4, uv1, uv2, uv4, texture, intensity, zbuffer)
		#force_inline fill_up(p2, p4, p3, uv2, uv4, uv3, texture, intensity, zbuffer)
	}


}


draw_filled_triangle :: proc(p1, p2, p3: Vec3, color: rl.Color, zbuffer: ^ZBuffer) {
	ps := []Vec3{p1, p2, p3}

	sort.quick_sort_proc(ps, proc(p1, p2: Vec3) -> int {
		return sort.compare_f32s(p1.y, p2.y)
	})
	p1, p2, p3 := ps[0], ps[1], ps[2]

	floor_xy(&p1)
	floor_xy(&p2)
	floor_xy(&p3)

	if p2.y == p3.y {
		#force_inline fill_bottom(p1, p2, p3, color, zbuffer)
	} else if p1.y == p2.y {
		#force_inline fill_up(p1, p2, p3, color, zbuffer)
	} else {

		t := (p2.y - p1.y) / (p3.y - p1.y)
		p4 := Vec3{p1.x + t * (p3.x - p1.x), p2.y, 0}
		weights := barycentric_weights(p1.xy, p2.xy, p3.xy, p4.xy)
		z := (weights[0] * p1.z + weights[1] * p2.z + weights[2] * p3.z)

		p4.z = z
		#force_inline fill_bottom(p1, p2, p4, color, zbuffer)
		#force_inline fill_up(p2, p4, p3, color, zbuffer)
	}
}


fill_bottom :: proc {
	fill_bottom_flat,
	fill_bottom_textured,
}

fill_up :: proc {
	fill_up_flat,
	fill_up_textured,
}

fill_bottom_flat :: proc(p1, p2, p3: Vec3, color: rl.Color, zbuffer: ^ZBuffer) {
	p2, p3 := p2, p3
	if p3.x < p2.x {
		p2, p3 = p3, p2
	}
	total_height := p3.y - p1.y
	for i := p1.y; i <= p3.y; i += 1 {
		t := (i - p1.y) / total_height
		l := #force_inline math.floor(p1.x + t * (p2.x - p1.x))
		r := #force_inline math.floor(p1.x + t * (p3.x - p1.x))

		for current_x := l; current_x <= r; current_x += 1 {
			current_p := Vec2{current_x, i}
			weights := barycentric_weights(p1.xy, p2.xy, p3.xy, current_p)
			z := 1 - (weights[0] * p1.z + weights[1] * p2.z + weights[2] * p3.z)
			draw_with_ztest(Vec3{current_p.x, current_p.y, z}, color, zbuffer)
		}
	}
}

fill_bottom_textured :: proc(
	p1, p2, p3: Vec3,
	uv1, uv2, uv3: Vec2,
	texture: Texture,
	intensity: f32,
	zbuffer: ^ZBuffer,
) {
	p2, p3 := p2, p3
	uv2, uv3 := uv2, uv3
	if p3.x < p2.x {
		p2, p3 = p3, p2
		uv2, uv3 = uv3, uv2
	}
	total_height := p3.y - p1.y
	for i := p1.y; i <= p3.y; i += 1 {
		t := (i - p1.y) / total_height
		l := #force_inline math.floor(p1.x + t * (p2.x - p1.x))
		r := #force_inline math.floor(p1.x + t * (p3.x - p1.x))

		for current_x := l; current_x <= r; current_x += 1 {
			current_p := Vec2{current_x, i}
			weights := barycentric_weights(p1.xy, p2.xy, p3.xy, current_p)
			z := (weights[0] * p1.z + weights[1] * p2.z + weights[2] * p3.z)
			one_sub_z := 1 - z

			UV :=
				((uv1 * p1.z) * weights[0] +
					(uv2 * p2.z) * weights[1] +
					(uv3 * p3.z) * weights[2]) *
				(1 / z)

			texX := i32(UV.x * f32(texture.width)) % texture.width
			texY := i32(UV.y * f32(texture.height)) % texture.height

			tex := texture.pixels[texY * texture.width + texX]

			tex = rl.Color {
				u8(f32(tex.r) * intensity),
				u8(f32(tex.g) * intensity),
				u8(f32(tex.b) * intensity),
				tex.a,
			}

			draw_with_ztest(Vec3{current_p.x, current_p.y, one_sub_z}, tex, zbuffer)
		}
	}
}


fill_up_flat :: proc(p1, p2, p3: Vec3, color: rl.Color, zbuffer: ^ZBuffer) {
	p1, p2 := p1, p2
	if p1.x > p2.x {
		p1, p2 = p2, p1
	}
	total_height := p3.y - p1.y

	for i := p3.y; i >= p2.y; i -= 1 {
		t := (i - p1.y) / total_height // NOTE: Dont use slope accumulate way to do this, it cause floating point error, same as fill bottom
		l := #force_inline math.floor(p1.x + t * (p3.x - p1.x))
		r := #force_inline math.floor(p2.x + t * (p3.x - p2.x))
		for current_x := l; current_x <= r; current_x += 1 {
			current_p := Vec2{current_x, i}
			weights := barycentric_weights(p1.xy, p2.xy, p3.xy, current_p)
			z := 1 - (weights[0] * p1.z + weights[1] * p2.z + weights[2] * p3.z)
			draw_with_ztest(Vec3{current_p.x, current_p.y, z}, color, zbuffer)
		}

	}
}

fill_up_textured :: proc(
	p1, p2, p3: Vec3,
	uv1, uv2, uv3: Vec2,
	texture: Texture,
	intensity: f32,
	zbuffer: ^ZBuffer,
) {

	p1, p2 := p1, p2
	uv1, uv2 := uv1, uv2
	if p1.x > p2.x {
		p1, p2 = p2, p1
		uv1, uv2 = uv2, uv1
	}
	total_height := p3.y - p1.y

	for i := p3.y; i >= p2.y; i -= 1 {
		t := (i - p1.y) / total_height // NOTE: Dont use slope accumulate way to do this, it cause floating point error, same as fill bottom
		l := #force_inline math.floor(p1.x + t * (p3.x - p1.x))
		r := #force_inline math.floor(p2.x + t * (p3.x - p2.x))

		for current_x := l; current_x <= r; current_x += 1 {
			current_p := Vec2{current_x, i}
			weights := barycentric_weights(p1.xy, p2.xy, p3.xy, current_p)
			z := (weights[0] * p1.z + weights[1] * p2.z + weights[2] * p3.z)
			one_sub_z := 1 - z
			UV :=
				((uv1 * p1.z) * weights[0] +
					(uv2 * p2.z) * weights[1] +
					(uv3 * p3.z) * weights[2]) *
				(1 / z)

			texX := i32(UV.x * f32(texture.width)) % texture.width
			texY := i32(UV.y * f32(texture.height)) % texture.height

			tex := texture.pixels[texY * texture.width + texX]
			tex = rl.Color {
				u8(f32(tex.r) * intensity),
				u8(f32(tex.g) * intensity),
				u8(f32(tex.b) * intensity),
				tex.a,
			}

			draw_with_ztest(Vec3{current_p.x, current_p.y, one_sub_z}, tex, zbuffer)
		}

	}
}


is_point_outside_viewport :: proc(p: Vec2) -> bool {
	return p.x < 0 || p.x >= SCREEN_WIDTH || p.y < 0 || p.y >= SCREEN_HEIGHT
}

barycentric_weights :: proc(a, b, c, p: Vec2) -> Vec3 {
	pbc_size2 := math.abs(cross_2d(c - b, p - b))
	pac_size2 := math.abs(cross_2d(c - a, p - a))
	pab_size2 := math.abs(cross_2d(a - b, p - b))
	total := pbc_size2 + pac_size2 + pab_size2
	return Vec3{pbc_size2, pac_size2, pab_size2} / total
}

draw_with_ztest :: proc(p: Vec3, color: rl.Color, zbuffer: ^ZBuffer) {
	if is_point_outside_viewport(p.xy) do return
	if ztest(p, zbuffer) {
		rl.DrawPixelV(p.xy, color)
		zbuffer[index_screen_p(p.xy)] = p.z
	}
}

index_screen_p :: proc(p: Vec2) -> int {
	return int(p.y) * SCREEN_WIDTH + int(p.x)
}

ztest :: proc(p: Vec3, zbuffer: ^ZBuffer) -> bool {
	return zbuffer[index_screen_p(p.xy)] > p.z
}

