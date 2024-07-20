
draw_set_colour(c_yellow)
draw_text(32, 32, $"dist: {string_format(walk_dist, 0, 8)}\nnext: {next_step}")
draw_set_color(c_white)

begin
	var paint = palette[current_paint]
	var topc = paint.colour
	var ns_c = merge_color(c_black, topc, 0.8)
	var ew_c = merge_color(c_black, topc, 0.6)
	matrix_push(matrix_world)
	
	var pic_scale = 64
	var pic_x = room_width - pic_scale - 16
	var pic_y = 64+16
	
	matrix_set(matrix_world, matrix_build(pic_x, pic_y, 0, 0,0,0, pic_scale, -pic_scale, 1))
	draw_primitive_begin(pr_trianglelist)
	
	var hofs = (1-paint.shape.get_tall()) * 1.1
	var x0 = paint.shape.x0
	var x1 = paint.shape.x1
	// top
	draw_vertex_color(0, 0-hofs, topc, 1)
	draw_vertex_color(1, 0.5-hofs, topc, 1)
	draw_vertex_color(0, 1-hofs, topc, 1)
	draw_vertex_color(0, 0-hofs, topc, 1)
	draw_vertex_color(0, 1-hofs, topc, 1)
	draw_vertex_color(-1, 0.5-hofs, topc, 1)

	// ew
	draw_vertex_color(0, -1.1, ew_c, 1)
	draw_vertex_color(0, 0-hofs, ew_c, 1)
	draw_vertex_color(-1, 0.5-hofs, ew_c, 1)
	draw_vertex_color(0, -1.1, ew_c, 1)
	draw_vertex_color(-1, 0.5-hofs, ew_c, 1)
	draw_vertex_color(-1, -0.6, ew_c, 1)

	// ns
	draw_vertex_color(1, -0.6, ns_c, 1)
	draw_vertex_color(1, 0.5-hofs, ns_c, 1)
	draw_vertex_color(0, -1.1, ns_c, 1)
	draw_vertex_color(0, -1.1, ns_c, 1)
	draw_vertex_color(1, 0.5-hofs, ns_c, 1)
	draw_vertex_color(0, 0-hofs, ns_c, 1)

	draw_primitive_end()
	matrix_pop(matrix_world)
end
