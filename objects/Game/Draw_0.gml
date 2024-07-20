
map_renderer.draw()


gpu_set_depth(-1)
draw_rectangle_size(0, 0, map.wide, map.tall, true)
gpu_set_depth(0)
	
begin
	var xbloc = mouse.block_x
	var ybloc = mouse.block_y
	var t = get_timer() / 1000000
	
	draw_set_color(merge_colour(c_white, c_yellow, cos(t*pi*2)*0.5+0.5))
	draw_set_alpha(0.5)
	draw_primitive_begin(pr_trianglefan)
	var infl = (sin(t*pi*4)*0.5+0.5)*(0.5/16)
	draw_vertex(xbloc-infl, ybloc-infl)
	draw_vertex(xbloc+1+infl, ybloc-infl)
	draw_vertex(xbloc+1+infl, ybloc+1+infl)
	draw_vertex(xbloc-infl, ybloc+1+infl)
	
	draw_primitive_end()
	draw_set_color(c_white)
	draw_set_alpha(1.0)
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
	var plrx0 = rect_get_x0(player.box)
	var plry0 = rect_get_y0(player.box)
	var plrx1 = rect_get_x1(player.box)
	var plry1 = rect_get_y1(player.box)
	
	var pxnow = lerp(player.xprevious, player.x, tfac)
	var pynow = lerp(player.yprevious, player.y, tfac)
	var peyenow = pynow+player.eyeline
	
	var xx = lerp(rect_get_x0(player.previous_box), plrx0, tfac)
	var yy = lerp(rect_get_y0(player.previous_box), plry0, tfac)
		
	viewcast.xdirection = mouse.world_x-viewcast.x
	viewcast.ydirection = mouse.world_y-viewcast.y
	
	if keyboard_check(ord("E"))
	{
		if abs(viewcast.xdirection) < abs(viewcast.ydirection)
		{
			viewcast.xdirection = 0
		}
		else
		{
			viewcast.ydirection = 0
		}
	}
	
	viewcast.sync_box()
	
	
	#region voxelboxelcastle
	
	__init_cast()
	viewcaster.set_box(viewcast.box)
	vec_set_xy(viewcaster.direction, viewcast.xdirection, viewcast.ydirection)
	ray_box_ctx.setup_box_ray(
		rect_get_x0(viewcast.box),
		rect_get_y0(viewcast.box),
		rect_get_x1(viewcast.box),
		rect_get_y1(viewcast.box),
		viewcast.xdirection,
		viewcast.ydirection
	)
	
	viewcaster.sweep()

	begin
		
		if __hit_time < infinity
		{
			var vdx = viewcast.xdirection*__hit_time
			var vdy = viewcast.ydirection*__hit_time
			var vx = rect_get_centre_x(viewcast.box)
			var vy = rect_get_centre_y(viewcast.box)
			var dx = vx+viewcast.xdirection*__hit_time
			var dy = vy+viewcast.ydirection*__hit_time
			
			//draw_arrow(vx-1, vy-1, dx-1, dy-1, 8/16)
			
			draw_set_color(c_white)
			rect_draw(viewcast.box_absolute, viewcast.x+vdx, viewcast.y+vdy)
		}
		
		var vx0 = viewcaster.box_min[0]
		var vy0 = viewcaster.box_min[1]
		var vx1 = viewcaster.box_max[0]
		var vy1 = viewcaster.box_max[1]
			
		vx0 = rect_get_x0(viewcast.box)
		vy0 = rect_get_y0(viewcast.box)
		vx1 = rect_get_x1(viewcast.box)
		vy1 = rect_get_y1(viewcast.box)
			
		draw_set_color(c_ltgrey)
		draw_primitive_begin(pr_linestrip)
		draw_vertex(vx0, vy0)
		draw_vertex(vx1, vy0)
		draw_vertex(vx1, vy1)
		draw_vertex(vx0, vy1)
		draw_vertex(vx0, vy0)
		draw_primitive_end()
			
		vx0 += viewcast.xdirection
		vy0 += viewcast.ydirection
		vx1 += viewcast.xdirection
		vy1 += viewcast.ydirection

		draw_set_color(c_ltgrey)
		draw_primitive_begin(pr_linestrip)
		draw_vertex(vx0, vy0)
		draw_vertex(vx1, vy0)
		draw_vertex(vx1, vy1)
		draw_vertex(vx0, vy1)
		draw_vertex(vx0, vy0)
		draw_primitive_end()
			
		var xd = viewcast.xdirection < 0 ? -1 : +1
		var yd = viewcast.ydirection < 0 ? -1 : +1
		var xs = rect_get_wide(viewcast.box_absolute) * 0.5
		var ys = rect_get_tall(viewcast.box_absolute) * 0.5
		var xc = rect_get_centre_x(viewcast.box)
		var yc = rect_get_centre_y(viewcast.box)
			
		var px = -yd * xs + xc
		var py = +xd * ys + yc
		draw_primitive_begin(pr_linelist)
		draw_vertex(px, py)
		draw_vertex(px+viewcast.xdirection, py+viewcast.ydirection)
		px = +yd * xs + xc
		py = -xd * ys + yc
		draw_vertex(px, py)
		draw_vertex(px+viewcast.xdirection, py+viewcast.ydirection)
		draw_primitive_end()
			
	end
	#endregion
	
	//begin
	//	draw_set_color(c_fuchsia)
	//	draw_set_alpha(0.5)
	//	draw_primitive_begin(pr_trianglelist)
	//	for (var i = array_length(player.temp_adj_colliders); i > 0;)
	//	{
	//		var collider = player.temp_adj_colliders[--i]
	//		if i <= 1
	//		{
	//			break
	//		}
	//		var x0 = rect_get_x0(collider)
	//		var y0 = rect_get_y0(collider)
	//		var x1 = rect_get_x1(collider)
	//		var y1 = rect_get_y1(collider)
			
			
	//		draw_vertex(x0, y0)
	//		draw_vertex(x1, y0)
	//		draw_vertex(x0, y1)
	//		draw_vertex(x1, y0)
	//		draw_vertex(x0, y1)
	//		draw_vertex(x1, y1)
			
	//	}
	//	draw_primitive_end()
	//	draw_set_alpha(1.0)
	//end
		
	matrix_set(matrix_world, matrix_build_offset(xx-plrx0, yy-plry0, 0))
	draw_set_color(c_grey)
	draw_primitive_begin(pr_linestrip)
	draw_vertex(plrx0, plry0)
	draw_vertex(plrx1, plry0)
	draw_vertex(plrx1, plry1)
	draw_vertex(plrx0, plry1)
	draw_vertex(plrx0, plry0)
	draw_primitive_end()

	xx = lerp(player.xprevious, player.x, tfac)
	yy = lerp(player.yprevious, player.y, tfac)

	matrix_stack_push(matrix_build_offset(xx, yy, 0))
	
	matrix_set(matrix_world, matrix_stack_top())
	matrix_stack_clear()
	draw_set_color(c_white)
		
	var abx0 = rect_get_x0(player.box_absolute)
	var aby0 = rect_get_y0(player.box_absolute)
	var abx1 = rect_get_x1(player.box_absolute)
	var aby1 = rect_get_y1(player.box_absolute)
	
	//var t = get_timer() / 1000000
	//draw_set_halign(fa_center)
	//draw_text_in_world((abx0+abx1)*0.5, aby1+0.2, "WOW!!!", 0.5)
	
	//draw_set_halign(fa_left)

	
	draw_primitive_begin(pr_linestrip)
	draw_vertex(abx0, aby0)
	draw_vertex(abx1, aby0)
	draw_vertex(abx1, aby1)
	draw_vertex(abx0, aby1)
	draw_vertex(abx0, aby0)
	draw_primitive_end()
		
	draw_primitive_begin(pr_linelist)
	draw_set_color(c_red)
	
	draw_vertex(abx0, aby0+player.eyeline)
	draw_vertex(abx1, aby0+player.eyeline)
	
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
	
end
	
	
draw_set_color(c_white)



