
///@arg x
///@arg y
///@arg z
///@arg view_matrix
///@arg proj_matrix
function world_to_screen (_x, _y, _z, v, p)
{
	// ortho
	var dpx = p[0] * (dot_product_3d(_x, _y, _z, v[0], v[4], v[8]) + v[12])
	var dpy = p[5] * (dot_product_3d(_x, _y, _z, v[1], v[5], v[9]) + v[13])
	var sx = p[12] + dpx
	var sy = p[13] + dpy
	var w = 1;
	
	// perspective
	if (p[15] == 0)
	{
		
		w = dot_product_3d(_x, _y, _z, v[2], v[10], v[14])
		
		if (w == 0)
		{
			return [-infinity, -infinity, 1];
		}
		
		w = 1 / w;
		sx = p[8] + dpx * w;
		sy = p[9] + dpy * w;
	}
	
	//return [sx * .5 + .5, -sy * .5 + .5, w];
	return [sx, -sy, w];
}

__M_STACK_W = array_create(16)
__M_CURSOR_W = 0

__M_STACK_V = array_create(16)
__M_CURSOR_V = 0

__M_STACK_P = array_create(16)
__M_CURSOR_P = 0


function matrix_push (which)
{
	switch (which)
	{
		case matrix_world:
			global.__M_STACK_W[global.__M_CURSOR_W++] = matrix_get(matrix_world)
			break
		case matrix_view:
			global.__M_STACK_V[global.__M_CURSOR_V++] = matrix_get(matrix_view)
			break
		case matrix_projection:
			global.__M_STACK_P[global.__M_CURSOR_P++] = matrix_get(matrix_projection)
			break
	}
}


function matrix_pop (which)
{
	switch (which)
	{
		case matrix_world:
			matrix_set(matrix_world, global.__M_STACK_W[--global.__M_CURSOR_W])
			break
		case matrix_view:
			matrix_set(matrix_view, global.__M_STACK_V[--global.__M_CURSOR_V])
			break
		case matrix_projection:
			matrix_set(matrix_projection, global.__M_STACK_P[--global.__M_CURSOR_P])
			break
	}
}
