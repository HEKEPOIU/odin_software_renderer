package main

import rl "vendor:raylib"

Texture :: struct {
	width:  i32,
	height: i32,
	pixels: [^]rl.Color,
}


load_texture_form_file :: proc(file: cstring) -> Texture {
	img := rl.LoadImage(file)
	texture := Texture {
		width = img.width,
		height = img.height,
		pixels = rl.LoadImageColors(img)
	}
	rl.UnloadImage(img)

	return texture
}
