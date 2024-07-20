var map_wide = map.wide
var map_tall = map.tall

var map_x0 = rect_get_x0(map.bounds)
var map_y0 = rect_get_y0(map.bounds)
var map_x1 = rect_get_x1(map.bounds)
var map_y1 = rect_get_y1(map.bounds)

matrix_push(matrix_world)

var cel_size = map.cel_size

var marg = 1 / cel_size
for (var yy = map_tall; --yy >= 0;)
{
	for (var xx = map_wide; --xx >= 0;)
	{
		var cel = map.get(xx, yy)
		
		var rc = cel.render_count()
		if rc <= 0
		{
			continue
		}
		
		draw_set_color(cel.colour)
		for (var i = rc; --i >= 0;)
		{
			var shape = cel.render_shapes[i]
			draw_primitive_begin(pr_trianglefan)
		
			var x0 = xx+rect_get_x0(shape)
			var y0 = yy+rect_get_y0(shape)
			var x1 = xx+rect_get_x1(shape)
			var y1 = yy+rect_get_y1(shape)
		
			draw_vertex(x0, y0)
			draw_vertex(x1, y0)
			draw_vertex(x1, y1)
			draw_vertex(x0, y1)
			draw_primitive_end()
		}
	}
}

begin
	
	draw_set_alpha(0.5)
	
	var mw = map.wide
	var mh = map.tall
	
	draw_primitive_begin(pr_linelist)
	draw_set_color(c_black)

	for (var i = 0; i <= mw; i++)
	{
		draw_vertex(i, 0)
		draw_vertex(i, mh)
	}
	draw_primitive_end()
	
	draw_primitive_begin(pr_linelist)
	draw_set_color(c_black)
	for (var i = 0; i <= mh; i++)
	{
		draw_vertex(0, i)
		draw_vertex(mw, i)
	}
	draw_primitive_end()
	
	draw_set_color(c_white)
	draw_set_alpha(1)

end

hit.did = trace(trace_predicate)

draw_set_color(c_yellow)
draw_primitive_begin(pr_linelist)
var rr = 0.25
draw_vertex(ray.x0()-rr, ray.y0()-rr)
draw_vertex(ray.x0()+rr, ray.y0()+rr)
draw_vertex(ray.x0()+rr, ray.y0()-rr)
draw_vertex(ray.x0()-rr, ray.y0()+rr)
draw_primitive_end()

begin
	ray.draw_box()
	ray.draw_box(ray.get_dir_x(), ray.get_dir_y())
end


if hit.did
{
	draw_set_color(c_green)
	draw_set_alpha(0.5)
	draw_primitive_begin(pr_trianglefan)
	draw_vertex(rect_x0(hit.box), rect_y0(hit.box))
	draw_vertex(rect_x1(hit.box), rect_y0(hit.box))
	draw_vertex(rect_x1(hit.box), rect_y1(hit.box))
	draw_vertex(rect_x0(hit.box), rect_y1(hit.box))
	
	draw_primitive_end()
	draw_set_alpha(1)
}


begin
	//draw_set_alpha(0.5)
	draw_set_color(hit.did ? c_green : c_red)
	draw_primitive_begin(pr_linelist)
	
	var rx0 = ray.x0()
	var ry0 = ray.y0()
	var rx1 = (ray.get_dir_x()*hit.time) + rx0
	var ry1 = (ray.get_dir_y()*hit.time) + ry0
	draw_vertex(rx0, ry0)
	draw_vertex(rx1, ry1)
	
	if hit.did
	{
		draw_vertex(rx1, ry1)
		draw_vertex(rx1+boxcast_context.normal_x, ry1+boxcast_context.normal_y)
	}
	
	//if mouse_check_button_pressed(mb_right)
	//{
	//	ray.set_start(
	//		ray.get_dir_x()*(hit.time-math_get_epsilon())+rx0,
	//		ray.get_dir_y()*(hit.time-math_get_epsilon())+ry0
	//	)
	//}
	draw_set_alpha(1)
	draw_primitive_end()
	
	if hit.did
	{
		draw_set_alpha(0.5)
		ray.draw_box(rx1-rx0, ry1-ry0, true)
	}
	
end

draw_set_alpha(1)
draw_set_color(c_white)

matrix_pop(matrix_world)
