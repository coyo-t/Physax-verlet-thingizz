
//!#import rect.* in Rect

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
		
		var xx = lerp(rect_get_x0(player_previous_box), plrx0, tfac)
		var yy = lerp(rect_get_y0(player_previous_box), plry0, tfac)
		
		matrix_set(matrix_world, matrix_build(
			xx-plrx0,
			yy-plry0,
			0,
			0,0,0,
			1,1,1
		))
		draw_primitive_begin(pr_linestrip)
		draw_set_color(c_grey)
		draw_vertex(plrx0, plry0)
		draw_vertex(plrx1, plry0)
		draw_vertex(plrx1, plry1)
		draw_vertex(plrx0, plry1)
		draw_vertex(plrx0, plry0)
		draw_primitive_end()
		xx = lerp(player_xprevious, player_x, tfac)
		yy = lerp(player_yprevious, player_y, tfac)
		matrix_set(matrix_world, matrix_build(
			xx,
			yy,
			0,
			0,0,0,
			1,1,1
		))
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
		draw_vertex(xx, yy)
		draw_vertex(xx+sz, yy)
		draw_set_color(c_yellow)
		draw_vertex(xx, yy)
		draw_vertex(xx, yy+sz)
		draw_primitive_end()
		draw_set_color(c_white)
		draw_primitive_end()
	end
	
	
	draw_set_color(c_white)

end

