package main

import rl "vendor:raylib"


apply_transform :: proc(original: []Vec3, mat: Mat4x4, result: ^[]Vec3) {
	for i in 0 ..< len(original) {
		result[i] = mat4_mul_vec3(mat, original[i])
	}
}

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Renderer")

	camera := Camera{{0, 0, 3.0}, {0, 0, 0}}
	translation := Vec3{0.0, 0.0, 0.0}
	rotation := Vec3{0.0, 0.0, 0.0}
	scale: f32 = 1.0

	render_modes_count :: 3
	render_mode: i8 = render_modes_count - 1

	projection := make_projection_mat(FOV, SCREEN_WIDTH, SCREEN_HEIGHT, NEAR_PLANE, FAR_PLANE)
	cube := make_cube()

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()
		handle_inputs(&translation, &rotation, &scale, &render_mode, render_modes_count, dt)
		translation_mat := make_translate_mat(translation.x, translation.y, translation.z)
		rotation_mat := make_rotation_mat_degree(rotation.x, rotation.y, rotation.z)
		scale_mat := make_scale_mat(scale, scale, scale)

		model_mat :=    translation_mat * rotation_mat* scale_mat
		view_mat := make_view_mat(camera.position, camera.target)
		mv_mat :=  view_mat * model_mat
		apply_transform(cube.vertices, mv_mat, &cube.view_vertices)

		rl.BeginDrawing()
		switch render_mode {
		case 0:
			draw_wireframe(cube.view_vertices, cube.triangles, projection, rl.GREEN, false)
		case 1:
			draw_wireframe(cube.view_vertices, cube.triangles, projection, rl.GREEN, true)
		case 2: 
			draw_unit(cube.view_vertices, cube.triangles, projection, rl.GREEN, nil)
		}

		rl.EndDrawing()
		rl.ClearBackground(rl.BLACK)
	}

	rl.CloseWindow()
}

