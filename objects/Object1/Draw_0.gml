




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
		var xx = lerp(player_previous_box.x0, player_box.x0, tfac)
		var yy = lerp(player_previous_box.y0, player_box.y0, tfac)
		
		matrix_set(matrix_world, matrix_build(
			xx-player_box.x0,
			yy-player_box.y0,
			0,
			0,0,0,
			1,1,1
		))
		draw_primitive_begin(pr_linestrip)
		draw_set_color(c_grey)
		draw_vertex(player_box.x0, player_box.y0)
		draw_vertex(player_box.x1, player_box.y0)
		draw_vertex(player_box.x1, player_box.y1)
		draw_vertex(player_box.x0, player_box.y1)
		draw_vertex(player_box.x0, player_box.y0)
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
		draw_vertex(player_box_absolute.x0, player_box_absolute.y0)
		draw_vertex(player_box_absolute.x1, player_box_absolute.y0)
		draw_vertex(player_box_absolute.x1, player_box_absolute.y1)
		draw_vertex(player_box_absolute.x0, player_box_absolute.y1)
		draw_vertex(player_box_absolute.x0, player_box_absolute.y0)
		draw_primitive_end()
		
		matrix_pop(matrix_world)
		
		sz = 2
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
	
	
	var colliders = map.get_colliders(player_box)
	draw_set_color(c_orange)
	array_foreach(colliders, function (collider) {
		draw_primitive_begin(pr_linestrip)
		draw_vertex(collider.x0,collider.y0)
		draw_vertex(collider.x1,collider.y0)
		draw_vertex(collider.x1,collider.y1)
		draw_vertex(collider.x0,collider.y1)
		draw_vertex(collider.x0,collider.y0)
		draw_primitive_end()
	})
	draw_set_color(c_white)

end

