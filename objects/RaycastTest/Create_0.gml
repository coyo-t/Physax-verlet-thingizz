

begin // blocs
	IDS = []
	function __BLOC () constructor begin
	
		numeric = 0
		colour = c_black
		render_shapes = [rect_create(0, 0, 1, 1)]
		collision_shapes = [rect_create(0, 0, 1, 1)]
	
		static collider_count = function ()
		{
			return array_length(collision_shapes)
		}
	
		static render_count = function ()
		{
			return array_length(render_shapes)
		}
	
		static is = function (_other)
		{
			return numeric == _other.numeric
		}
	end
	
	var register = method(self, function (thing)
	{
		// this is silly
		static FUCK = static_get(new __BLOC())
		static_set(thing, FUCK)
		thing.numeric = array_length(IDS)
		array_push(IDS, thing)
		return thing
	})
	var full_bloc = rect_create(0, 0, 1, 1)
	
	ID_NON = register({
		colour: c_black,
		render_shapes: [],
		collision_shapes: [],
	})

	ID_BLOC = register({
		colour: c_grey,
		render_shapes: [full_bloc],
		collision_shapes: [full_bloc],
	})
	
	var pole_bloc = rect_create(0.25, 0.25, 0.75, 0.75)
	ID_POLE = register({
		colour: c_orange,
		render_shapes: [pole_bloc],
		collision_shapes: [pole_bloc],
	})
	
	var checkers_bloc = [
		rect_create(0.0, 0.0, 0.5, 0.5),
		rect_create(0.5, 0.5, 1.0, 1.0),
	]
	ID_CHECKER = register({
		colour: c_orange,
		render_shapes: checkers_bloc,
		collision_shapes: checkers_bloc,
		
	})
	
	var fr = 1/16
	var stairs_bloc = array_create(16)
	for (var i = 0; i < 16; i++)
	{
		stairs_bloc[i] = rect_normalize(rect_create(0, 1-i*fr, (i+1)*fr, 1-(i+1)*fr))
	}
	
	ID_STAIRS = register({
		colour: c_grey,
		render_shapes: stairs_bloc,
		collision_shapes: stairs_bloc,
	})
end

begin // map load stuff
	PROCEDURES = {}
	var REG = method(self, function(_ch, _cb) {
		PROCEDURES[$ _ch] = method(self, _cb)
	})
	
	REG("#", function (_x, _y) {
		map.fast_set(_x, _y, ID_BLOC)
	})
	
	REG("P", function (_x, _y) {
		with ray
		{
			set_origin(_x+0.5, _y+0.5)
		}
	})
	
	REG("O", function (_x, _y) {
		map.fast_set(_x, _y, ID_POLE)
	})
	
	REG("C", function (_x, _y) {
		map.fast_set(_x, _y, ID_CHECKER)
	})
	
	REG("S", function (_x, _y) {
		map.fast_set(_x, _y, ID_STAIRS)
	})
	
	function create_map ()
	{
		var map_wide = string_length(argument[0])
		var map_tall = argument_count
		
		map.resize(map_wide, map_tall)
		map.clear(ID_NON)
	
		for (var yy = map_tall; --yy >= 0;)
		{
			for (var xx = map_wide; --xx >= 0;)
			{
				var cel = string_char_at(argument[map_tall-yy-1], xx+1)
				
				if struct_exists(PROCEDURES, cel)
				{
					struct_get(PROCEDURES, cel)(xx, yy)
				}
			}
		}
	}
end

map = begin
	wide: 1,
	tall: 1,
	cel_size: 64,
	data: ds_grid_create(1, 1),
	bounds: rect_create(),
	
	///@self
	point_in_bounds: function (_x, _y)
	{
		_x = floor(_x)
		_y = floor(_y)
		return 0 <= _x and _x < wide and 0 <= _y and _y < tall
	},
	
	///@self
	xytoi: function (_x, _y)
	{
		return _y*wide+_x
	},
	
	///@self
	fast_set: function (_x, _y, _type)
	{
		data[# _x, _y] = _type.numeric
	},
	
	///@self
	get: function (_x, _y)
	{
		if point_in_bounds(_x, _y)
		{
			return other.IDS[data[# _x, _y]]
		}
		return other.ID_NON
	},
	
	///@self
	set: function (_x, _y, _type)
	{
		if not point_in_bounds(_x, _y)
		{
			return false
		}
		var at = data[# _x, _y]
		if at == _type.numeric
		{
			return false
		}
		data[# _x, _y] = _type.numeric
		return true
	},
	
	///@self
	resize: function (_wide, _tall)
	{
		wide = _wide
		tall = _tall
		ds_grid_resize(data, _wide, _tall)
		var x0 = (room_width / 2) - (_wide * cel_size) / 2
		var y0 = (room_height / 2) - (_tall * cel_size) / 2
		rect_set_corners(bounds,
			x0,
			y0,
			x0+_wide * cel_size,
			y0+_tall * cel_size
		)
	},
	
	///@self
	clear: function (_with)
	{
		ds_grid_clear(data, _with.numeric)
	},
end

ray = begin
	//x0:0,
	//y0:0,
	//x1:1,
	//y1:0,
	
	start_point: vec_create(0, 0),
	end_point:   vec_create(1, 0),
	
	box: rect_create(),
	src_box: rect_create(),
	
	///@self
	get_dir_x: function ()
	{
		return x1() - x0()
	},
	
	///@self
	get_dir_y: function ()
	{
		return y1() - y0()
	},
	
	///@self
	update_box: function ()
	{
		var _x = start_point[Vec.x]
		var _y = start_point[Vec.y]
		rect_set_corners(
			box,
			rect_x0(src_box)+_x,
			rect_y0(src_box)+_y,
			rect_x1(src_box)+_x,
			rect_y1(src_box)+_y
		)
	},
	
	///@self
	set_start: function (_x, _y)
	{
		vec_set_xy(start_point, _x, _y)
	},
	
	///@self
	set_end: function (_x, _y)
	{
		vec_set_xy(end_point, _x, _y)
	},
	
	///@self
	set_origin: function (_x, _y)
	{
		var xd = end_point[Vec.x]-start_point[Vec.x]
		var yd = end_point[Vec.y]-start_point[Vec.y]
		vec_set_xy(start_point, _x, _y)
		vec_set_xy(end_point, _x+xd, _y+yd)
	},
	
	///@self
	set_direction: function (_x, _y)
	{
		set_end(start_point[Vec.x]+_x, start_point[Vec.y]+_y)
	},
	
	///@self
	draw_box: function (_xofs=0, _yofs=0, _solid=false)
	{
		var x0 = rect_x0(box)+_xofs
		var y0 = rect_y0(box)+_yofs
		var x1 = rect_x1(box)+_xofs
		var y1 = rect_y1(box)+_yofs
		
		if _solid
		{
			draw_primitive_begin(pr_trianglefan)
			draw_vertex(x0, y0)
			draw_vertex(x1, y0)
			draw_vertex(x1, y1)
			draw_vertex(x0, y1)
		}
		else
		{
			draw_primitive_begin(pr_linestrip)
			draw_vertex(x0, y0)
			draw_vertex(x1, y0)
			draw_vertex(x1, y1)
			draw_vertex(x0, y1)
			draw_vertex(x0, y0)
		}
		draw_primitive_end()
	},
	
	x0: function () { return start_point[Vec.x] },
	y0: function () { return start_point[Vec.y] },
	x1: function () { return end_point[Vec.x] },
	y1: function () { return end_point[Vec.y] },
end

hit = begin
	did: false,
	x: 0,
	y: 0,
	///@self
	reset: function ()
	{
		time = 1
		did = false
	},
	box: rect_create(),
	time: 1,
end

mouse = begin
	x: 0,
	y: 0,
	map_x: 0,
	map_y: 0,
	world_x:0,
	world_y:0,
end

boxcast_context = new RayRectContext2()


function __Tracer () constructor begin
	static __DEFAULT_CB = function (_x, _y) { return false }
	static __CONT_BATCH = 1
	static __HARD_STOP = 2
	
	box_min = vec_create()
	box_max = vec_create()
	box_direction = vec_create()

	leading_corner  = vec_create()
	trailing_corner = vec_create()
	
	leading_cel  = vec_create()
	trailing_cel = vec_create()
	
	leading_start = vec_create()
	trailing_offset = vec_create()
	
	step = vec_create()
	delta_dist = vec_create()
	next_dist  = vec_create()
	normalized = vec_create()
	
	axis = Vec.x
	
	iter_count = 0
	current_dist = 0
	max_dist = 0
	inverse_max_dist = infinity
	
	__iter_mode = __CONT_BATCH
	
	__cel_callback = __DEFAULT_CB
	
	static __calc_iter_count = function (_start, _direction)
	{
		var x0 = _start[0]
		var y0 = _start[1]
		var x1 = x0 + _direction[0]
		var y1 = y0 + _direction[1]
		return abs(floor(x1)-floor(x0))+abs(floor(y1)-floor(y0))+1
	}
	
	static set_cel_callback = function (_cb)
	{
		__cel_callback = _cb ?? __DEFAULT_CB
	}
	
	static setup_corners = function (_x0, _y0, _x1, _y1, _xdirection, _ydirection)
	{
		vec_set_xy(box_min, _x0, _y0)
		vec_set_xy(box_max, _x1, _y1)
		vec_set_xy(box_direction, _xdirection, _ydirection)
		__setup()
	}
	
	static set_batch_mode = function (_b)
	{
		switch _b
		{
			case "continue_batch":
				__iter_mode = __CONT_BATCH
				break
			case "hard_stop":
				__iter_mode = __HARD_STOP
				break
		}
	}
	
	static __setup = function ()
	{
		max_dist = vec_sqr_length(box_direction)
		
		if max_dist <= 0
		{
			return false
		}
		
		max_dist = sqrt(max_dist)
		inverse_max_dist = 1.0 / max_dist
		
		var backwards = vec_get_temp()
		var dir_positive = vec_get_temp()
		
		for (var i = 0; i < Vec.sizeof; i++)
		{
			var rd = box_direction[i]
			var dp = rd >= 0
			dir_positive[i] = dp
			step[i] = dp ? +1 : -1
			time_delta[i] = rd == 0 ? infinity : abs(1.0 / rd)
			
			trailing_corner[i] = dp ? box_min[i] : box_max[i]
			trailing_cel[i] = __trailing_to_cel(trailing_corner[i], step[i])
			
			backwards[i] = dp
				? (trailing_corner[i]-trailing_cel[i])
				: (trailing_cel[i]+1-trailing_corner[i])
			backwards[i] *= -delta_dist[i]
			
			normalized[i] = rd * inverse_max_dist
		}
		
		var tc = max(backwards[Vec.x], backwards[Vec.y]) * max_dist
		
		for (var i = 0; i < Vec.sizeof; i++)
		{
			leading_corner[i] = dp ? box_max[i] : box_min[i]
			trailing_corner[i] += normalized[i] * tc
			
			leading_cel  = __leading_to_cel(leading_corner[i], step[i])
			trailing_cel = __trailing_to_cel(trailing_corner[i], step[i])
			
			next_dist[i] = dir_positive[i]
				? (leading_cel[i] + 1 - leading_corner[i])
				: (leading_corner[i] - leading_cel[i])
			next_dist[i] *= time_delta[i]
		
			leading_start[i] = leading_corner[i]
			trailing_offset[i] = leading_corner[i] - trailing_corner[i]
		}
		
		iter_count = __calc_iter_count(leading_corner, box_direction)
		axis = __lesser_axis()
		
		return true
	}
	
	static __leading_to_cel = function(coord, step)
	{
		return floor(coord - step * math_get_epsilon())
	}
	
	static __trailing_to_cel = function (coord, step)
	{
		return floor(coord + step * math_get_epsilon())
	}
	
	static __lesser_axis = function ()
	{
		return next_dist[Vec.x] < next_dist[Vec.y] ? Vec.x : Vec.y
	}
	
	static __advance = function ()
	{
		var naxis = __lesser_axis()

		current_dist = next_dist[naxis]
		leading_cel[naxis] += step[naxis]
		next_dist[naxis] += delta_dist[naxis]
		
		var rp = current_dist * max_dist
		
		for (var i = 0; i < Vec.sizeof; i++)
		{
			leading_corner[i] = leading_start[i] + normalized[i] * rp
			trailing_corner[i] = leading_corner[i] - trailing_offset[i]
			trailing_indices[i] = __trailing_to_cel(trailing_corner[i], step[i])
		}
		
		return naxis
	}
	
	static __test = function ()
	{
		var stepx = step[Vec.x]
		var stepy = step[Vec.y]
		
		var x0, y0
		if axis == Vec.x
		{
			x0 = leading_indices[Vec.x]
			y0 = trailing_indices[Vec.y]
		}
		else if axis == Vec.y
		{
			x0 = trailing_indices[Vec.x]
			y0 = leading_indices[Vec.y]
		}

		var x1 = leading_indices[Vec.x] + step[Vec.x]
		var y1 = leading_indices[Vec.y] + step[Vec.y]
		
		var xcount = abs(x1-x0)
		var ycount = abs(y1-y0)
		
		var any = false
		var yc, yy
		for (var xx = x0; --xcount >= 0; xx+=stepx)
		{
			yc = ycount
			for (yy = y0; --yc >= 0; yy+=stepy)
			{
				if __cel_callback(xx, yy)
				{
					switch __iter_mode
					{
						case __CONT_BATCH:
							any = true
							break
						case __HARD_STOP:
							return true
					}
				}
			}
		}
		return any
	}

	static trace = function ()
	{
		axis = __lesser_axis()
		
		for (var i = 0; i < iter_count; i++)
		{
			var cel_x = leading_cel[Vec.x]
			var cel_y = leading_cel[Vec.y]
			
			if __test()
			{
				return true
			}
			
			axis = __advance()
		}
		
		return false
	}

end



///@self
function trace (_get_bloc_callback)
{
	hit.reset()
	
	var ray_xd = ray.get_dir_x()
	var ray_yd = ray.get_dir_y()
	
	var time_max = power(ray_xd, 2) + power(ray_yd, 2)
	
	if time_max <= 0
	{
		return false
	}
	
	static calc_iter_count = function (_start, _direction)
	{
		var x0 = _start[0]
		var y0 = _start[1]
		var x1 = x0 + _direction[0]
		var y1 = y0 + _direction[1]
		return abs(floor(x1)-floor(x0))+abs(floor(y1)-floor(y0))+1
	}
	
	static ray_origin = vec_create()
	static ray_direction = vec_create()
	static box_min = vec_create()
	static box_max = vec_create()
	static leading_corner  = vec_create()
	static trailing_corner = vec_create()
	static leading_cel  = vec_create()
	static trailing_cel = vec_create()
	
	vec_set_xy(ray_origin, ray.x0(), ray.y0())
	vec_set_xy(ray_direction, ray.get_dir_x(), ray.get_dir_y())
	vec_set_xy(box_min, rect_x0(ray.box), rect_y0(ray.box))
	vec_set_xy(box_max, rect_x1(ray.box), rect_y1(ray.box))
	
	//boxcast_context.setup_endpoints(ray.x0(), ray.y0(), ray.x1(), ray.y1())
	boxcast_context.setup_with_corners(
		box_min[0],
		box_min[1],
		box_max[0],
		box_max[1],
		ray_direction[0],
		ray_direction[1]
	)
	

	static ray_end = vec_create()
	static cel  = vec_create()
	static step = vec_create()
	static time_delta = vec_create()
	
	static time_next_backwards = vec_create()
	static time_next  = vec_create()
	static normal = vec_create()
	
	time_max = sqrt(time_max)

	for (var i = 0, ivt_t = 1 / time_max; i < Vec.sizeof; i++)
	{
		var rd = ray_direction[i]
		var dir_positive = rd >= 0
		
		leading_corner[i]  = dir_positive ? box_max[i] : box_min[i]
		trailing_corner[i] = dir_positive ? box_min[i] : box_max[i]
		
		//var ro = ray_origin[i]
		var ro = leading_corner[i]
		
		ray_end[i] = ro+rd
		step[i] = dir_positive ? +1 : -1
		cel[i] = floor(ro)
		time_delta[i] = rd == 0 ? infinity : abs(1.0 / rd)
		
		var ta = (ro - cel[i]) * time_delta[i]
		var tb = (cel[i] + 1 - ro) * time_delta[i]
		
		time_next[i] = dir_positive ? tb : ta
		time_next_backwards[i] = dir_positive ? ta : tb
		normal[i] = rd * ivt_t
	}
	
	var axis = Vec.x
	begin
		var rdx = ray_direction[0]
		var rdy = ray_direction[1]
		var lcx = leading_corner[0]
		var lcy = leading_corner[1]
		var tcx = trailing_corner[0]
		var tcy = trailing_corner[1]
		draw_primitive_begin(pr_linelist)
		draw_set_color(c_grey)

		draw_vertex(lcx, tcy)
		draw_vertex(lcx+rdx, tcy+rdy)
		
		draw_vertex(tcx, lcy)
		draw_vertex(tcx+rdx, lcy+rdy)

		draw_set_color(c_lime)
		var tx = (rdx < 0 ? (floor(tcx)+1-tcx) : tcx-floor(tcx)) * -time_delta[0]
		var ty = (rdy < 0 ? (floor(tcy)+1-tcy) : tcy-floor(tcy)) * -time_delta[1]
		var tc = max(tx, ty) * time_max
		
		tx = normal[0]*tc
		ty = normal[1]*tc
		
		draw_vertex(tcx, tcy)
		draw_vertex(tcx+tx, tcy+ty)
		
		draw_primitive_end()
		
		draw_set_alpha(0.25)
		draw_primitive_begin(pr_trianglefan)
		var ttx = floor(tcx+tx + step[0]*math_get_epsilon())
		var tty = floor(tcy+ty + step[1]*math_get_epsilon())
		draw_vertex(ttx, tty)
		draw_vertex(ttx+1, tty)
		draw_vertex(ttx+1, tty+1)
		draw_vertex(ttx, tty+1)
		draw_primitive_end()
		
		draw_set_alpha(0.5)
		ray.draw_box(tx, ty)
		draw_set_alpha(1)
	end
	//var maxiter = calc_iter_count(ray_origin, ray_direction)
	var maxiter = calc_iter_count(leading_corner, ray_direction)
	var time = 0
	
	
	
	while (--maxiter) >= 0
	{
		var cel_x = cel[Vec.x]
		var cel_y = cel[Vec.y]
		
		begin
			draw_set_color(c_orange)
			draw_primitive_begin(pr_linestrip)
			draw_vertex(cel_x, cel_y)
			draw_vertex(cel_x+1, cel_y)
			draw_vertex(cel_x+1, cel_y+1)
			draw_vertex(cel_x, cel_y+1)
			draw_vertex(cel_x, cel_y)
			draw_primitive_end()
		end
		
		if _get_bloc_callback(cel_x, cel_y)
		{
			return true
		}
		
		if time_next[Vec.x] < time_next[Vec.y]
		{
			axis = Vec.x
		}
		else
		{
			axis = Vec.y
		}
		
		var dt = time-time_next[axis]
		time = time_next[axis]
		time_next[axis] += time_delta[axis]
		cel[axis] += step[axis]
		
		var dotx = normal[0] * time * time_max
		var doty = normal[1] * time * time_max
		
		draw_set_color(axis == Vec.x ? c_red : c_yellow)
		draw_set_alpha(0.4)
		draw_circle(leading_corner[0]+dotx-1, leading_corner[1]+doty-1, 1/16, false)
		draw_set_alpha(0.2)
		ray.draw_box(dotx, doty, true)
		draw_set_alpha(1)

	}
	return false
}

/*
///@self
function trace (_get_bloc_callback)
{
	hit.reset()
	
	var ray_xd = ray.get_dir_x()
	var ray_yd = ray.get_dir_y()
	
	var time_max = power(ray_xd, 2) + power(ray_yd, 2)
	
	if time_max <= 0
	{
		return false
	}
	
	boxcast_context.setup_endpoints(ray.x0(), ray.y0(), ray.x1(), ray.y1())

	
	static ray_origin = vec_create()
	static ray_direction = vec_create()
	static ray_end = vec_create()
	static cel  = vec_create()
	static step = vec_create()
	static time_delta = vec_create()
	
	static time_next_backwards = vec_create()
	static time_next  = vec_create()
	static normal = vec_create()
	
	vec_set_xy(ray_origin, ray.x0(), ray.y0())
	vec_set_xy(ray_direction, ray.get_dir_x(), ray.get_dir_y())

	time_max = sqrt(time_max)

	for (var i = 0, ivt_t = 1 / time_max; i < Vec.sizeof; i++)
	{
		var ro = ray_origin[i]
		var rd = ray_direction[i]
		ray_end[i] = ro+rd
		var dir_positive = rd >= 0
		step[i] = dir_positive ? +1 : -1
		cel[i] = floor(ro)
		time_delta[i] = rd == 0 ? infinity : abs(1.0 / rd)
		
		var ta = (ro - cel[i]) * time_delta[i]
		var tb = (cel[i] + 1 - ro) * time_delta[i]
		
		time_next[i] = dir_positive ? tb : ta
		time_next_backwards[i] = dir_positive ? ta : tb
		normal[i] = rd * ivt_t
	}
	
	var axis = Vec.x
	begin
		var cd = min(time_next_backwards[0], time_next_backwards[1]) * time_max
		draw_set_color(c_fuchsia)
		draw_arrow(
			ray_origin[0]-1,
			ray_origin[1]-1,
			ray_origin[0]-normal[0]*cd-1,
			ray_origin[1]-normal[1]*cd-1,
			1/16
		)
	end
	var maxiter = abs(floor(ray_end[0])-floor(ray_origin[0]))+abs(floor(ray_end[1])-floor(ray_origin[1]))+1
	var time = 0
	while (--maxiter) >= 0
	{
		var cel_x = cel[Vec.x]
		var cel_y = cel[Vec.y]
		
		begin
			draw_set_color(c_orange)
			draw_primitive_begin(pr_linestrip)
			draw_vertex(cel_x, cel_y)
			draw_vertex(cel_x+1, cel_y)
			draw_vertex(cel_x+1, cel_y+1)
			draw_vertex(cel_x, cel_y+1)
			draw_vertex(cel_x, cel_y)
			draw_primitive_end()
		end
		
		if _get_bloc_callback(cel_x, cel_y)
		{
			return true
		}
		
		if time_next[Vec.x] < time_next[Vec.y]
		{
			axis = Vec.x
		}
		else
		{
			axis = Vec.y
		}
		
		time = time_next[axis]
		time_next[axis] += time_delta[axis]
		cel[axis] += step[axis]
		
	}
	return false
}
*/

cam = new Camera()
m_view = matrix_build_identity()
m_proj = matrix_build_identity()

trace_predicate = function (_x, _y) {
	var type = map.get(_x, _y)
	var cc = type.collider_count()
	if cc <= 0
	{
		return false
	}
	
	var any = false
	var nearest = infinity
	var colliders = type.collision_shapes
	
	var temp_rect = rect_get_temp()
	
	for (var i = cc; --i >= 0;)
	{
		var collider = rect_set_from(temp_rect, colliders[i])
		rect_move(collider, _x, _y)
		var test = boxcast_context.test(
			rect_x0(collider),
			rect_y0(collider),
			rect_x1(collider),
			rect_y1(collider)
		)
		if test
		{
			var tt = boxcast_context.near_time
			if tt < hit.time
			{
				any = true
				hit.time = tt
				rect_set_from(hit.box, collider)
			}
		}
	}
	
	return any
}



#region setup

var bbw = (0.6) * 0.5
var bbh = 1.8
rect_set_corners(
	ray.src_box,
	-bbw,
	0,
	+bbw,
	bbh
)


create_map(
	"################",
	"#      ##      #",
	"#              #",
	"#              #",
	"#      P       #",
	"#              #",
	"#              #",
	"#              #",
	"#              #",
	"#              #",
	"##C     O   O  #",
	"#       #   #  #",
	"# #O     ###   #",
	"#    S         #",
	"################",
)

cam.x = map.wide / 2
cam.y = map.tall / 2

trace_predicate = method(self, trace_predicate)

#endregion

