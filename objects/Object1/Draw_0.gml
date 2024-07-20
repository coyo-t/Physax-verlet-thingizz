
map.draw()

begin
	gpu_set_depth(-1)
	draw_rectangle_size(0, 0, map.wide, map.tall, true)
	gpu_set_depth(0)
	
	begin
		var xbloc = cursor_x
		var ybloc = cursor_y
		draw_set_color(c_yellow)
		draw_rectangle_size(xbloc, ybloc, 1, 1, true)
		draw_set_color(c_white)
	end
	
	var sz = 8
	draw_primitive_begin(pr_linelist)
	draw_set_color(c_dkgrey)
	draw_vertex(-200, 0)
	draw_vertex(map.wide+200, 0)
	
	draw_set_color(c_red)
	draw_vertex(0, 0)
	draw_vertex(sz, 0)
	draw_set_color(c_yellow)
	draw_vertex(0, 0)
	draw_vertex(0, sz)
	draw_primitive_end()
	draw_set_color(c_white)
	
	begin
		matrix_push(matrix_world)
		var tfac = timer.get_tfac()
		var plrx0 = rect_get_x0(player_box)
		var plry0 = rect_get_y0(player_box)
		var plrx1 = rect_get_x1(player_box)
		var plry1 = rect_get_y1(player_box)
		
		var pxnow = lerp(player_xprevious, player_x, tfac)
		var pynow = lerp(player_yprevious, player_y, tfac)
		var peyenow = pynow+player_eyeline
		
		var xx = lerp(rect_get_x0(player_previous_box), plrx0, tfac)
		var yy = lerp(rect_get_y0(player_previous_box), plry0, tfac)
		
		viewcast_x = pxnow
		viewcast_y = peyenow
		viewcast_xdirection = world_mouse_x-viewcast_x
		viewcast_ydirection = world_mouse_y-viewcast_y
		rect_set_from(viewcast_box, viewcast_box_absolute)
		rect_move(viewcast_box, viewcast_x, viewcast_y)
		
		viewcaster.set_box(viewcast_box)
		vec_set_xy(viewcaster.direction, viewcast_xdirection, viewcast_ydirection)
		
		var trace_result = viewcaster.sweep()
		__DEBUG_STRING = string_join("\n",
			$"{power(trace_result, 2)}",
			$"{power(viewcast_xdirection, 2)+power(viewcast_ydirection,2)}",
		) 
		
		draw_primitive_begin(pr_linelist)
		draw_vertex(viewcast_x, viewcast_y)
		draw_vertex(viewcast_x+viewcast_xdirection, viewcast_y+viewcast_ydirection)
		draw_primitive_end()
		

		
		begin
			var vx0 = viewcaster.box_min[0]
			var vy0 = viewcaster.box_min[1]
			var vx1 = viewcaster.box_max[0]
			var vy1 = viewcaster.box_max[1]
			
			draw_set_color(c_white)
			draw_primitive_begin(pr_linestrip)
			draw_vertex(vx0, vy0)
			draw_vertex(vx1, vy0)
			draw_vertex(vx1, vy1)
			draw_vertex(vx0, vy1)
			draw_vertex(vx0, vy0)
			draw_primitive_end()
		end
		
		matrix_set(matrix_world, matrix_build(
			xx-plrx0,
			yy-plry0,
			0,
			0,0,0,
			1,1,1
		))
		draw_set_color(c_grey)
		draw_primitive_begin(pr_linestrip)
		draw_vertex(plrx0, plry0)
		draw_vertex(plrx1, plry0)
		draw_vertex(plrx1, plry1)
		draw_vertex(plrx0, plry1)
		draw_vertex(plrx0, plry0)
		draw_primitive_end()
		xx = lerp(player_xprevious, player_x, tfac)
		yy = lerp(player_yprevious, player_y, tfac)

		matrix_stack_push(matrix_build(
			xx,
			yy,
			0,
			0,0,0,
			1,1,1
		))
		
		matrix_set(matrix_world, matrix_stack_top())
		matrix_stack_clear()
		draw_primitive_begin(pr_linestrip)
		draw_set_color(c_white)
		var abx0 = rect_get_x0(player_box_absolute)
		var aby0 = rect_get_y0(player_box_absolute)
		var abx1 = rect_get_x1(player_box_absolute)
		var aby1 = rect_get_y1(player_box_absolute)
		draw_vertex(abx0, aby0)
		draw_vertex(abx1, aby0)
		draw_vertex(abx1, aby1)
		draw_vertex(abx0, aby1)
		draw_vertex(abx0, aby0)
		draw_primitive_end()
		
		draw_primitive_begin(pr_linelist)
		draw_set_color(c_red)
		
		draw_vertex(abx0, aby0+player_eyeline)
		draw_vertex(abx1, aby0+player_eyeline)
		
		draw_primitive_end()
		draw_set_color(c_white)
		
		matrix_pop(matrix_world)
		
		sz = 0.25
		draw_primitive_begin(pr_linelist)
		draw_set_color(c_red)
		draw_vertex(pxnow, pynow)
		draw_vertex(pxnow+sz, pynow)
		draw_set_color(c_yellow)
		draw_vertex(pxnow, pynow)
		draw_vertex(pxnow, pynow+sz)
		draw_primitive_end()
		draw_set_color(c_white)
		draw_primitive_end()
	end
	
	
	draw_set_color(c_white)

end

