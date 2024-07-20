
function draw_rectangle_size (_x, _y, _wide, _tall, _outline)
{
	var x1 = _x+_wide
	var y1 = _y+_tall
	if _outline
	{
		draw_primitive_begin(pr_linestrip)
		draw_vertex(_x, _y)
		draw_vertex(x1, _y)
		draw_vertex(x1, y1)
		draw_vertex(_x, y1)
		draw_vertex(_x, _y)
	}
	else
	{
		draw_primitive_begin(pr_trianglestrip)
		draw_vertex(_x, _y)
		draw_vertex(x1, _y)
		draw_vertex(_x, y1)
		draw_vertex(x1, y1)
	}
	draw_primitive_end()
}
