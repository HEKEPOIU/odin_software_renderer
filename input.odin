package main

import rl "vendor:raylib"

handle_inputs :: proc(
	translation, rotation: ^Vec3,
	scale: ^f32,
	render_mode: ^i8,
	render_modes_count: i8,
	delta_time: f32,
) {
	linear_step: f32 = (rl.IsKeyDown(rl.KeyboardKey.LEFT_SHIFT) ? 0.25 : 1) * delta_time
	angular_step: f32 = (rl.IsKeyDown(rl.KeyboardKey.LEFT_SHIFT) ? 12 : 48) * delta_time
	if rl.IsKeyDown(rl.KeyboardKey.W) do translation.z += linear_step
	if rl.IsKeyDown(rl.KeyboardKey.S) do translation.z -= linear_step
	if rl.IsKeyDown(rl.KeyboardKey.A) do translation.x += linear_step
	if rl.IsKeyDown(rl.KeyboardKey.D) do translation.x -= linear_step
	if rl.IsKeyDown(rl.KeyboardKey.E) do translation.y += linear_step
	if rl.IsKeyDown(rl.KeyboardKey.Q) do translation.y -= linear_step

	if rl.IsKeyDown(rl.KeyboardKey.J) do rotation.x -= angular_step
	if rl.IsKeyDown(rl.KeyboardKey.L) do rotation.x += angular_step
	if rl.IsKeyDown(rl.KeyboardKey.O) do rotation.y += angular_step
	if rl.IsKeyDown(rl.KeyboardKey.U) do rotation.y -= angular_step
	if rl.IsKeyDown(rl.KeyboardKey.I) do rotation.z += angular_step
	if rl.IsKeyDown(rl.KeyboardKey.K) do rotation.z -= angular_step

	if rl.IsKeyDown(rl.KeyboardKey.KP_ADD) do scale^ += linear_step
	if rl.IsKeyDown(rl.KeyboardKey.KP_SUBTRACT) do scale^ -= linear_step

	if rl.IsKeyPressed(rl.KeyboardKey.LEFT) {
		render_mode^ = (render_mode^ + render_modes_count - 1) % render_modes_count
	} else if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) {
		render_mode^ = (render_mode^ + 1) % render_modes_count
	}

}

