package main

import s "core:sort"

sort :: proc{
	sort_points
}

sort_points :: proc(ps : []Vec2) {
	s.quick_sort_proc(ps, proc(p1, p2 : Vec2) ->int {
		return s.compare_f32s(p1.y, p2.y)
	})
}
