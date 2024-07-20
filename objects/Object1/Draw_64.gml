//!#import rect.* in Rect

draw_set_colour(c_yellow)
draw_text(32, 32, $"dist: {string_format(walk_dist, 0, 8)}\nnext: {next_step}\n"+__DEBUG_STRING)
draw_set_color(c_white)

begin
	
	
	
	if paint_changed
	{
		var paint = palette_get_current()
		var shapes = paint.get_render_shapes()
		//var topc = merge_colour(paint.colour, c_yellow, 0.2)
		//var ns_c = merge_color(c_aqua, topc, 0.8)
		//var ew_c = merge_color(c_red, topc, 0.6)
		
		
		var topc = paint.colour
		var ns_c = merge_color(c_black, topc, 0.8)
		var ew_c = merge_color(c_black, topc, 0.6)
		vertex_begin(palette_vb, palette_vb_format)
		for (var i = array_length(shapes); i > 0;)
		{
			var shape = shapes[--i]
		
			var x0 = rect_get_x0(shape)
			var y0 = rect_get_y0(shape)
			var z0 = x0
			var x1 = rect_get_x1(shape)
			var y1 = rect_get_y1(shape)
			var z1 = x1
		
		
			// top
			palette_vertex(x0, y1, z0, topc)
			palette_vertex(x1, y1, z1, topc)
						palette_vertex(x1, y1, z0, topc)

			palette_vertex(x0, y1, z0, topc)
			palette_vertex(x0, y1, z1, topc)
			palette_vertex(x1, y1, z1, topc)
		
			// east-west
			palette_vertex(x1, y0, z0, ew_c)
			palette_vertex(x1, y1, z0, ew_c)
			palette_vertex(x1, y1, z1, ew_c)

			palette_vertex(x1, y1, z1, ew_c)
			palette_vertex(x1, y0, z1, ew_c)
			palette_vertex(x1, y0, z0, ew_c)
		
			// north-south
			palette_vertex(x0, y0, z1, ns_c)
			palette_vertex(x1, y1, z1, ns_c)
			palette_vertex(x0, y1, z1, ns_c)

			palette_vertex(x0, y0, z1, ns_c)
			palette_vertex(x1, y0, z1, ns_c)
			palette_vertex(x1, y1, z1, ns_c)

		}
		vertex_end(palette_vb)
	
	}
	
	gpu_push_state()
	gpu_set_cullmode(cull_clockwise)
	gpu_set_zwriteenable(true)
	gpu_set_ztestenable(true)

	var pic_scale = 64
	//var pic_x = mouse_x
	//var pic_y = mouse_y
	var pic_x = room_width - pic_scale - 16
	var pic_y = 64+16
	matrix_push(matrix_world)
	var trans = matrix_build(pic_x, pic_y, 0, 0,0,0, pic_scale, pic_scale, 1)

	matrix_set(matrix_world, trans)
	matrix_stack_clear()
	
	//matrix_push(matrix_world)
	matrix_set(matrix_world, matrix_multiply(paint_matrix, matrix_get(matrix_world)))

	vertex_submit(palette_vb, pr_trianglelist, -1)
	//matrix_pop(matrix_world)
	
	//draw_primitive_begin(pr_linelist)
	//var xx = 0.5
	//var yy = 0.5
	//var zz = 0.5
	//var sz = 2
	//gpu_set_depth(zz)
	//draw_set_color(c_red)
	//draw_vertex(xx, yy)
	//draw_vertex(xx+sz, yy)
	//draw_set_color(c_yellow)
	//draw_vertex(xx, yy)
	//draw_vertex(xx, yy+sz)
	//draw_set_color(c_aqua)
	//gpu_set_depth(zz)
	//draw_vertex(xx, yy)
	//gpu_set_depth(zz+sz)
	//draw_vertex(xx, yy)
	//draw_primitive_end()


	
	
	gpu_pop_state()
	matrix_pop(matrix_world)
	
	draw_set_color(c_white)

end
