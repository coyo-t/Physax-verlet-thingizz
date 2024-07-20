var map_wide = map.wide
var map_tall = map.tall

var map_x0 = rect_get_x0(map.bounds)
var map_y0 = rect_get_y0(map.bounds)
var map_x1 = rect_get_x1(map.bounds)
var map_y1 = rect_get_y1(map.bounds)

matrix_push(matrix_world)

var cel_size = map.cel_size

matrix_set(matrix_world, matrix_build(
	map_x0,map_y0,0,
	0,0,0,
	(map_x1-map_x0)/map_wide, (map_y1-map_y0)/map_tall, 1
))

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

draw_set_color(c_yellow)
for (var i = ds_list_size(hit.points); --i >= 0; )
{
	var pt = hit.points[| i]
	draw_circle(pt[Vec.x]-1, pt[Vec.y]-1, 0.05, false)
}

for (var i = ds_list_size(hit.cels); --i >= 0; )
{
	var pt = hit.cels[| i]
	var xx = pt[Vec.x]
	var yy = pt[Vec.y]
	var sz = 0.001
	draw_primitive_begin(pr_linestrip)
	draw_vertex(xx+sz, yy+sz)
	draw_vertex(xx+1-sz, yy+sz)
	draw_vertex(xx+1-sz, yy+1-sz)
	draw_vertex(xx+sz, yy+1-sz)
	draw_vertex(xx+sz, yy+sz)
	draw_primitive_end()
}

draw_set_color(c_yellow)
draw_primitive_begin(pr_linelist)
var rr = 0.25
draw_vertex(ray.x0-rr, ray.y0-rr)
draw_vertex(ray.x0+rr, ray.y0+rr)
draw_vertex(ray.x0+rr, ray.y0-rr)
draw_vertex(ray.x0-rr, ray.y0+rr)
draw_primitive_end()

draw_arrow(
	ray.x0-1,
	ray.y0-1,
	ray.x0+(ray.get_dir_x()*hit.time)-1,
	ray.y0+(ray.get_dir_y()*hit.time)-1,
	0.25
)

draw_set_color(c_white)

matrix_pop(matrix_world)
