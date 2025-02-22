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

//trace(trace_predicate)
trace_hull(trace_predicate2)
draw_set_color(c_white)
draw_set_alpha(1)
	
draw_set_color(c_yellow)
draw_primitive_begin(pr_linelist)
var rr = 0.25
draw_vertex(ray.x0()-rr, ray.y0()-rr)
draw_vertex(ray.x0()+rr, ray.y0()+rr)
draw_vertex(ray.x0()+rr, ray.y0()-rr)
draw_vertex(ray.x0()-rr, ray.y0()+rr)
draw_primitive_end()

if trace_any
{
	draw_set_color(c_green)
	draw_set_alpha(0.5)
	draw_primitive_begin(pr_trianglefan)
	draw_vertex(rect_x0(trace_nearest_box), rect_y0(trace_nearest_box))
	draw_vertex(rect_x1(trace_nearest_box), rect_y0(trace_nearest_box))
	draw_vertex(rect_x1(trace_nearest_box), rect_y1(trace_nearest_box))
	draw_vertex(rect_x0(trace_nearest_box), rect_y1(trace_nearest_box))
	
	draw_primitive_end()
	draw_set_alpha(1)
}

ray.draw_box()

begin
	//draw_set_alpha(0.5)
	
	var nt = trace_any ? trace_nearest : 1.0
	
	var raydirx = ray.get_dir_x()
	var raydiry = ray.get_dir_y()
	
	var rx0 = ray.x0()
	var ry0 = ray.y0()
	
	var rhitx = raydirx*nt
	var rhity = raydiry*nt
	
	var rx1 = rhitx + rx0
	var ry1 = rhity + ry0
	
	var rxp = raydirx >= 0
	var ryp = raydiry >= 0
	var rb = ray.box
	
	var trailingx = rxp ? rect_x0(rb) : rect_x1(rb)
	var trailingy = ryp ? rect_y0(rb) : rect_y1(rb)
	var leadingx = rxp ? rect_x1(rb) : rect_x0(rb)
	var leadingy = ryp ? rect_y1(rb) : rect_y0(rb)
	
	draw_set_alpha(0.5)
	draw_set_color(c_grey)
	
	draw_primitive_begin(pr_trianglestrip)
	draw_vertex(leadingx, trailingy)
	draw_vertex(leadingx+rhitx, trailingy+rhity)
	draw_vertex(leadingx, leadingy)
	draw_vertex(leadingx+rhitx, leadingy+rhity)
	draw_vertex(trailingx, leadingy)
	draw_vertex(trailingx+rhitx, leadingy+rhity)

	
	draw_primitive_end()
	
	draw_primitive_begin(pr_linelist)
	draw_set_alpha(0.5)

	draw_set_color(c_ltgrey)
	draw_vertex(trailingx, leadingy)
	draw_vertex(trailingx+raydirx, leadingy+raydiry)
	draw_vertex(leadingx, trailingy)
	draw_vertex(leadingx+raydirx, trailingy+raydiry)
	
	draw_set_color(trace_any ? c_green : c_red)
	//draw_vertex(rx0, ry0)
	//draw_vertex(rx1, ry1)
	
	if trace_any
	{
		draw_vertex(rx1, ry1)
		draw_vertex(rx1+trace_nearest_normal[Vec.x], ry1+trace_nearest_normal[Vec.y])
	}
	
	draw_set_alpha(1)
	draw_primitive_end()
	
	
	draw_set_color(trace_any ? c_lime : c_grey)
	
	if trace_any
	{
	}
	draw_set_alpha(0.5)
	ray.draw_box(
		rx1-rx0,
		ry1-ry0,
		true
	)
	draw_set_color(c_white)
	ray.draw_box(
		raydirx,
		raydiry
	)
end

draw_set_alpha(1)
draw_set_color(c_white)

matrix_pop(matrix_world)
