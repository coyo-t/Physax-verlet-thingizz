
#macro MODE_OBJECT  0
#macro MODE_EDIT    1
#macro MODE_COMMAND 2

__DEBUG_STRING = ""


step_sounds_generic = get_sound_set("pl_step_generic") ///@is{array<sound>}
audio_set_master_gain(0, 0.5)

tick = method(self, function() /*=>*/ {
	player.tick()
})

timer = new Timer(20)
timer.time_scale = 1

map = new Map(16, 16)
map.fill_region(0, 0, map.wide, 1, global.stone)

map_renderer = new MapRenderer(map)
map.listener = map_renderer

cam = new Camera()
cam.x = map.wide / 2
cam.y = map.tall / 2

m_view = matrix_build_identity()
m_proj = matrix_build_identity()
m_inv_proj_view = matrix_build_identity()

mouse = {
	world_x/*:Val*/: 0.0,
	world_y/*:Val*/: 0.0,
	block_x/*:Int*/: 0,
	block_y/*:Int*/: 0,
}

//world_mouse_x = 0
//world_mouse_y = 0
//cursor_x = 0
//cursor_y = 0

viewcast_x = 0
viewcast_y = 0
viewcast_xdirection = 0
viewcast_ydirection = 0
viewcast_box_absolute = rect_create(-0.5, -0.5, 0.5, 0.5)
viewcast_box = rect_copy(viewcast_box_absolute)

__hit_x = 0
__hit_y = 0
var vc_getb = method(self, function (_x, _y) {
	var bloc = map.get_block(_x, _y)
	var collide = bloc.collideable()
	if collide
	{
		__hit_x = _x
		__hit_y = _y
	}
	return collide
})

var vc_onc = method(self, function (dist, axis, dir, remain)
{
	//show_debug_message($"dist: {dist}\naxis: {axis}\ndirection: {dir}\nremaining: {remain}")
	//draw_rectangle_size(__hit_x, __hit_y, 1, 1, true)
	//draw_arrow(
	//	viewcast_x-1,
	//	viewcast_y-1,
	//	viewcast_x+remain[0]-1,
	//	viewcast_y*remain[1]-1,
	//	4/16
	//)
	remain[axis] = 0
	return true
})

viewcaster = new RectVoxelSweeper(
	viewcast_box,
	vec_create(),
	vc_getb,
	vc_onc
)

#region palette

palette = array_filter(global.blocks_all, function(bloc) /*=>*/ {return bloc.show_in_palette()}) ///@is{array<Block>}

current_paint = 0 ///@is{int}
previous_paint = -1
paint_changed = true
vertex_format_begin()
vertex_format_add_position_3d()
vertex_format_add_color()
palette_vb_format = vertex_format_end()

palette_vb = vertex_create_buffer()

function palette_vertex (_x, _y, _z, _c)
{
	vertex_position_3d(palette_vb, _x, _y, _z)
	vertex_color(palette_vb, _c, 1)
}

function palette_get_current ()/*-> Block*/
{
	return palette[current_paint]
}

begin
	//var skew = [
	//	1, -0.5,   0, 0,
	//	1, +0.5,   0, 0,
	//	0,    1, 0.1, 0,
	//	0,    0,   0, 1
	//]
	var skew = [
		1,.5,0,0,
		0,-1,0,0,
		-1,.5,-1,0,
		0,0,0,1
	]
	var ofs = matrix_build_offset(-0.5, -0.5, -0.5)
	
	paint_matrix = matrix_multiply(ofs, skew)
	
	//paint_matrix = ofs
	matrix_stack_clear()

end

#endregion

wish_xdirection = 0
wish_ydirection = 0
wish_sneak = 0
player = new Player()

player.update_co(map.wide * 0.5, 1.5, true)
rect_set_from(viewcast_box_absolute, player.box_absolute)
