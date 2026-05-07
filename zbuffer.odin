package main

ZBuffer :: [SCREEN_WIDTH * SCREEN_HEIGHT]f32

clear_zbuffer :: proc(b: ^ZBuffer) {
	for &i in b {
		i = 999_999
	}
}
