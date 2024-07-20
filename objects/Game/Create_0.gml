
__DEBUG_STRING = ""


audio_set_master_gain(0, 0.1)

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


ray_box_ctx = new RayRectContext()


var vcb = rect_create(-0.1, -0.5, 0.1, 0.5)
viewcast = {
	x: map.wide / 2,
	y: map.tall / 2,
	xdirection: 0,
	ydirection: 0,
	box_absolute: vcb,
	box: rect_copy(vcb),
	///@self
	sync_box: function () {
		rect_set_from(box, box_absolute)
		rect_move(box, x, y)
	},
}

function __init_cast ()
{
	__hit_time = infinity
	__hit_any = false
	__closest_x = infinity
	__closest_y = infinity
	__pev_closest_x = infinity
	__pev_closest_y = infinity
	__probably_die = false
}

__hit_x = 0
__hit_y = 0
__hit_time = infinity
__hit_box = rect_create(0,0,0,0)

__closest_x = infinity
__closest_y = infinity
__pev_closest_x = infinity
__pev_closest_y = infinity
__hit_any = false
__probably_die = false
///@self
var vc_getb = method(self, function (_x, _y) {

	var bloc = map.get_block(_x, _y)
	
	if not bloc.collideable()
	{
		return false
	}
	__hit_x = _x
	__hit_y = _y
	var vcb = viewcast.box
	var hw = rect_get_wide(vcb) * 0.5
	var hh = rect_get_tall(vcb) * 0.5
	var colliders = bloc.get_colliders(_x, _y)
	var timezor = infinity
	for (var i = array_length(colliders); i > 0;)
	{
		var box = colliders[--i]
		var ht = ray_box_ctx.test_rect(box)
		draw_set_color(c_fuchsia)
		draw_set_alpha(0.5)
		rect_draw_filled(box)
		draw_set_color(c_white)
		draw_set_alpha(1)
		if ht and ray_box_ctx.hit_time < __hit_time
		{
			timezor = ray_box_ctx.hit_time
			
			rect_set_from(__hit_box, box)
		}
	}
	var any = timezor < infinity
	if any
	{
		__hit_time = timezor
		__hit_any = true
		
		__pev_closest_x = __closest_x
		__pev_closest_y = __closest_y
		__closest_x = _x
		__closest_y = _y
	}
	
	return any

})

var vc_onc = method(self, function (dist, axis, dir, remain)
{
	return false
	//return (
	//	(not is_infinity(__pev_closest_x) and not is_infinity(__pev_closest_y)) and
	//	(__pev_closest_x == __closest_x and __pev_closest_y == __closest_y)
	//)
	//return true//remain[0] == 0 and remain[1] == 0
})

viewcaster = new RectVoxelSweeper(
	viewcast.box,
	vec_create(),
	vc_getb,
	vc_onc
)
//viewcaster.set_hard_time_limit(min(map.wide, map.tall))


begin // palette
	var pred = function(bloc) {return bloc.show_in_palette()}
	palette/*Array<Block>*/ = array_filter(global.blocks_all, pred)
	
	current_paint = 0
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
end


wish_xdirection = 0
wish_ydirection = 0
wish_sneak = 0
player = new Player()

player.update_co(map.wide * 0.5, 1.5, true)
rect_set_from(viewcast.box_absolute, player.box_absolute)

entities/*:Array<Entity>*/ = []

array_push(entities, player)

function tick ()
{
	for (var i = array_length(entities); i > 0;)
	{
		entities[--i].tick()
	}
}
