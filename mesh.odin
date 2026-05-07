package main


Triangle :: [9]i32
Mesh :: struct {
	view_vertices:     []Vec3,
	transform_normals: []Vec3,
	vertices:          []Vec3,
	triangles:         []Triangle,
	normals:           []Vec3,
	uvs:               []Vec2,
}

make_cube :: proc() -> Mesh {
	vertices := make([]Vec3, 8)
	vertices[0] = Vec3{-1.0, -1.0, -1.0}
	vertices[1] = Vec3{-1.0, 1.0, -1.0}
	vertices[2] = Vec3{1.0, 1.0, -1.0}
	vertices[3] = Vec3{1.0, -1.0, -1.0}
	vertices[4] = Vec3{1.0, 1.0, 1.0}
	vertices[5] = Vec3{1.0, -1.0, 1.0}
	vertices[6] = Vec3{-1.0, 1.0, 1.0}
	vertices[7] = Vec3{-1.0, -1.0, 1.0}

	normals := make([]Vec3, 6)
	normals[0] = {0.0, 0.0, -1.0}
	normals[1] = {1.0, 0.0, 0.0}
	normals[2] = {0.0, 0.0, 1.0}
	normals[3] = {-1.0, 0.0, 0.0}
	normals[4] = {0.0, 1.0, 0.0}
	normals[5] = {0.0, -1.0, 0.0}

	uvs := make([]Vec2, 4)
	uvs[0] = {1.0, 1.0}
	uvs[1] = {1.0, 0.0}
	uvs[2] = {0.0, 0.0}
	uvs[3] = {0.0, 1.0}


	triangles := make([]Triangle, 12)

	// Front                 vert.     uvs       norm.
	triangles[0] = Triangle{0, 1, 2, 0, 1, 2, 0, 0, 0}
	triangles[1] = Triangle{0, 2, 3, 0, 2, 3, 0, 0, 0}
	// Right
	triangles[2] = Triangle{3, 2, 4, 0, 1, 2, 1, 1, 1}
	triangles[3] = Triangle{3, 4, 5, 0, 2, 3, 1, 1, 1}
	// Back
	triangles[4] = Triangle{5, 4, 6, 0, 1, 2, 2, 2, 2}
	triangles[5] = Triangle{5, 6, 7, 0, 2, 3, 2, 2, 2}
	// Left
	triangles[6] = Triangle{7, 6, 1, 0, 1, 2, 3, 3, 3}
	triangles[7] = Triangle{7, 1, 0, 0, 2, 3, 3, 3, 3}
	// Top
	triangles[8] = Triangle{1, 6, 4, 0, 1, 2, 4, 4, 4}
	triangles[9] = Triangle{1, 4, 2, 0, 2, 3, 4, 4, 4}
	// Bottom
	triangles[10] = Triangle{5, 7, 0, 0, 1, 2, 5, 5, 5}
	triangles[11] = Triangle{5, 0, 3, 0, 2, 3, 5, 5, 5}

	return Mesh {
		view_vertices = make([]Vec3, 8),
		transform_normals = make([]Vec3, 6),
		vertices = vertices,
		normals = normals,
		triangles = triangles,
		uvs = uvs,
	}
}

