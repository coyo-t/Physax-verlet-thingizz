

begin // blocs
	function get_shapes_from_room_instances (_room)
	{
		var nfo = room_get_info(_room, false, false, true, true, false)
		var layers = nfo.layers
		var outs = []
		
		var xs = 1 / nfo.width
		var ys = 1 / nfo.height
		
		for (var j = array_length(layers); --j >= 0;)
		{
			var elems = layers[j].elements
			
			for (var i = array_length(elems); --i >= 0;)
			{
				var elem = elems[i]
				if elem.type <> layerelementtype_sprite
				{
					continue
				}
				var _s = elem.sprite_index
				var _x = elem.x
				var _y = elem.y
				var _w = sprite_get_width(_s) * elem.image_xscale
				var _h = sprite_get_height(_s) * elem.image_yscale
				array_push(outs, rect_normalize(rect_create(
					_x*xs,
					1-_y*ys,
					(_x+_w)*xs,
					1-(_y+_h)*ys
				)))
			}
		}
		return outs
	}
	
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
		
		static get_colliders = function (_map/*Map*/, _x/*Int*/, _y/*Int*/, _outs/*DsList*/)/*Int*/
		{
			static FUCK = {OUTS:-1}
			static AAAA = method(FUCK, function (_collider) {
				ds_list_add(OUTS, _collider)
			})
			var cc = collider_count()
			if cc <> 0
			{
				FUCK.OUTS = _outs
				array_foreach(collision_shapes, AAAA)
			}
			return cc
		}
	end

	var register = method(self, function (thing)
	{
		thing ??= {}
		static handle_rect_array = function (_a)
		{
			if not is_array(_a) or array_length(_a) == 0
			{
				return []
			}
			if is_array(_a[0])
			{
				return _a
			}
			return [_a]
		}
		
		// this is silly
		var outs = new __BLOC()
		outs.numeric = array_length(IDS)
		
		outs.colour = thing[$ "colour"] ?? c_black
		
		outs.render_shapes = handle_rect_array(thing[$ "render_shapes"])
		outs.collision_shapes = handle_rect_array(thing[$ "collision_shapes"])
		
		// copy methods if given
		var names = struct_get_names(thing)
		for (var i = array_length(names); --i >= 0;)
		{
			var name = names[i]
			var cb = thing[$ names[i]]
			if is_callable(cb) and struct_exists(outs, name)
			{
				outs[$ name] = method(outs, cb)
			}
		}
		
		array_push(IDS, outs)
		return outs
	})
	
	var full_bloc = [rect_create(0, 0, 1, 1)]
	
	ID_NON = register()

	ID_BLOC = register({
		colour: c_grey,
		render_shapes: full_bloc,
		collision_shapes: full_bloc,
	})
	
	var pole_bloc = rect_create(0.25, 0.25, 0.75, 0.75)
	ID_POLE = register({
		colour: c_orange,
		render_shapes: pole_bloc,
		collision_shapes: pole_bloc,
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
	
	var stairs_bloc = get_shapes_from_room_instances(room_shape_superstairs)
	ID_STAIRS = register({
		colour: c_grey,
		render_shapes: stairs_bloc,
		collision_shapes: stairs_bloc,
	})
	
	var prec_rad = (1/16) * 2
	var prec_x0 = 0.5-prec_rad
	var prec_x1 = 0.5+prec_rad
	var prec_render = rect_create(prec_x0, 0, prec_x1, 1)
	var prec_collide = rect_create(prec_x0, 0, prec_x1, 1.5)
	ID_PRECARIOUS = register({
		colour: merge_color(c_orange, c_maroon, 0.5),
		render_shapes: prec_render,
		collision_shapes: prec_collide,
	})
	
	var cr_shape = rect_create(0, 0, 1, 1/16)
	ID_CARPET = register({
		colour: c_white,
		render_shapes: cr_shape,
		collision_shapes: cr_shape,
	})
	
	var lv_shape = get_shapes_from_room_instances(room_shape_sapling)
	ID_SAPLING = register({
		colour: c_lime,
		render_shapes: lv_shape,
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
	
	REG("|", function (_x, _y) {
		map.fast_set(_x, _y, ID_PRECARIOUS)
	})
	
	REG("_", function (_x, _y) {
		map.fast_set(_x, _y, ID_CARPET)
	})
	
	REG("T", function (_x, _y) {
		map.fast_set(_x, _y, ID_SAPLING)
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

#macro TRACE_FALSE (0)
#macro TRACE_CEL_CONTAINED_COLLIDERS (0b0000_0001)
#macro TRACE_COLLIDED (0b0000_0010)

function calc_iter_count (_start, _direction)
{
	return calc_iter_count_sep(
		_start[0],
		_start[1],
		_direction[0],
		_direction[1]
	)
}

function calc_iter_count_sep (_x, _y, _xd, _yd)
{
	return abs(floor(_x+_xd)-floor(_x))+abs(floor(_y+_yd)-floor(_y))+1
}

function trace_hull (_get_bloc_callback)
{
	trace_reset()
	hit.reset()
	
	var ray_direction = vec_get_temp(
		ray.get_dir_x(),
		ray.get_dir_y()
	)
	
	var time_max = vec_sqr_length(ray_direction)
	
	if time_max <= 0
	{
		return false
	}
	
	var src_rect = ray.box
	var rect = rect_get_temp(
		rect_x0(src_rect),
		rect_y0(src_rect)-1,
		rect_x1(src_rect),
		rect_y1(src_rect)
	)
	
	var box_src_min = vec_get_temp(rect_x0(src_rect), rect_y0(src_rect))
	var box_src_max = vec_get_temp(rect_x1(src_rect), rect_y1(src_rect))
	var box_min = vec_get_temp(rect_x0(rect), rect_y0(rect))
	var box_max = vec_get_temp(rect_x1(rect), rect_y1(rect))
	
	boxcast_context.setup_with_corners(
		rect_x0(src_rect), rect_y0(src_rect),
		rect_x1(src_rect), rect_y1(src_rect),
		ray_direction[Vec.x],
		ray_direction[Vec.y],
	)
	
	var step = vec_get_temp(
		ray_direction[Vec.x] >= 0 ? +1 : -1,
		ray_direction[Vec.y] >= 0 ? +1 : -1
	)
	
	// check rect
	// not ellegant, but "works" :/
	var did = false
	var bx0 = floor(rect_x0(rect) + math_get_epsilon())
	var by0 = floor(rect_y0(rect) + math_get_epsilon())
	var bx1 = floor(rect_x1(rect)+1-math_get_epsilon())
	var by1 = floor(rect_y1(rect)+1-math_get_epsilon())
	begin
		if trace_draw_debug
		{
			draw_set_color(c_purple)
			draw_set_alpha(0.5)
			draw_primitive_begin(pr_trianglefan)
			draw_vertex(bx0, by0)
			draw_vertex(bx1, by0)
			draw_vertex(bx1, by1)
			draw_vertex(bx0, by1)
			draw_primitive_end()
		}
		var xx, yy
		for (yy = by0; yy < by1; yy++)
		{
			for (xx = bx0; xx < bx1; xx++)
			{
				
				did |= _get_bloc_callback(xx, yy)
			}
		}
		draw_set_color(c_white)
		draw_set_alpha(1)
	end
	
	var leading_corner = vec_get_temp()
	var leading_cel = vec_get_temp()
	var trailing_corner = vec_get_temp()
	var trailing_cel = vec_get_temp()
	
	var leading_start = vec_get_temp()
	var trailing_start = vec_get_temp()
	
	var step = vec_get_temp()
	var time_delta = vec_get_temp()
	
	var time_next  = vec_get_temp()
	var normal = vec_get_temp()
	
	time_max = sqrt(time_max)
	var ivt_t = 1 / time_max
	
	for (var i = 0; i < Vec.sizeof; i++)
	{
		var rd = ray_direction[i]
		var dir_positive = rd >= 0
		step[i] = dir_positive ? +1 : -1
		
		leading_corner[i]  = dir_positive ? box_max[i] : box_min[i]
		trailing_corner[i] = dir_positive ? box_min[i] : box_max[i]
		
		var jit = step[i] * math_get_epsilon()
		
		leading_cel[i]  = floor(leading_corner[i]  - jit)
		trailing_cel[i] = floor(trailing_corner[i] + jit)
		
		time_delta[i] = rd == 0 ? infinity : abs(1.0 / rd)
		
		time_next[i] = dir_positive
			? (leading_cel[i] + 1 - leading_corner[i])
			: (leading_corner[i] - leading_cel[i])
		time_next[i] *= time_delta[i]
		
		normal[i] = rd * ivt_t
		
	}
	
	var stepx = step[Vec.x]
	var stepy = step[Vec.y]
	
	var leading_total  = vec_get_temp(
		stepx > 0 ? bx1 : bx0,
		stepy > 0 ? by1 : by0
	)
	var trailing_total = vec_get_temp(
		stepx > 0 ? bx0 : bx1,
		stepy > 0 ? by0 : by1
	)
	
	
	vec_set_from(leading_start, leading_corner)
	vec_set_from(trailing_start, trailing_corner)
	
	var axis = -1
	
	var dsc_count = max(
		floor(abs(rect_x1(rect)-rect_x0(rect))),
		floor(abs(rect_y1(rect)-rect_y0(rect)))
	)
	
	var maxiter = calc_iter_count_sep(
		leading_corner[0]-math_get_epsilon()*stepx,
		leading_corner[1]-math_get_epsilon()*stepy,
		ray_direction[0],
		ray_direction[1]
	) - 1
	var time = 0
	
	var xx, yy
	var ddid = did
	var RSLATCH = false

	var finalize = false
	var x0, y0, x1, y1
	while (--maxiter) >= 0
	{
		axis = time_next[Vec.x] < time_next[Vec.y] ? Vec.x : Vec.y
		
		begin
			time = time_next[axis]

			leading_cel[axis] += step[axis]
			time_next[axis] += time_delta[axis]
		
			for (var i = 0; i < Vec.sizeof; i++)
			{
				var nf = normal[i] * time * time_max
				leading_corner[i] = leading_start[i] + nf
				trailing_corner[i] = trailing_start[i] + nf
				trailing_cel[i] = floor(trailing_corner[i] + step[i] * math_get_epsilon())
			}
		end
		
		if ddid
		{
			break
		}
		
		if axis == Vec.x
		{
			x0 = leading_cel[Vec.x]
			y0 = trailing_cel[Vec.y]
			leading_total[Vec.x] += stepx
		}
		else if axis == Vec.y
		{
			x0 = trailing_cel[Vec.x]
			y0 = leading_cel[Vec.y]
			leading_total[Vec.y] += stepy
		}

		var x1 = leading_cel[Vec.x] + stepx
		var y1 = leading_cel[Vec.y] + stepy
		
		var xcount = abs(x1-x0)
		var ycount = abs(y1-y0)
			
		if trace_draw_debug begin
			var m0 = 1/16
			var m1 = 1-m0
			var xj = 1-(stepx*0.5+0.5)
			var yj = 1-(stepy*0.5+0.5)
			var xx0 = min(x0, x1)+m0+xj
			var yy0 = min(y0, y1)+m0+yj
			var xx1 = max(x0, x1)-m0+xj
			var yy1 = max(y0, y1)-m0+yj
			
			draw_set_color(c_orange)
			draw_set_alpha(0.5)
			draw_primitive_begin(pr_trianglefan)
			draw_vertex(xx0, yy0)
			draw_vertex(xx1, yy0)
			draw_vertex(xx1, yy1)
			draw_vertex(xx0, yy1)
			draw_primitive_end()
		end
			
		var yc
		for (xx = x0; --xcount >= 0; xx+=stepx)
		{
			yc = ycount
			for (yy = y0; --yc >= 0; yy+=stepy)
			{
				ddid |= _get_bloc_callback(xx, yy)
			}
		}
		
		did |= ddid
		if ddid then break
	}
	
	if did
	{
		var nearest = trace_nearest
		var tmp
		
		var cur_lx0 = trailing_corner[0]
		var cur_ly0 = trailing_corner[1]
		var cur_lx1 = leading_corner[0]
		var cur_ly1 = leading_corner[1]
		
		tmp = cur_lx0
		cur_lx0 = min(tmp, cur_lx1)
		cur_lx1 = max(tmp, cur_lx1)
		tmp = cur_ly0
		cur_ly0 = min(tmp, cur_ly1)
		cur_ly1 = max(tmp, cur_ly1)
		
		
		while (--maxiter) >= 0
		{
			var land_x = ray_direction[0] * nearest
			var land_y = ray_direction[1] * nearest
		
			var lsx0 = trailing_start[0] + land_x
			var lsy0 = trailing_start[1] + land_y
			var lsx1 = leading_start[0] + land_x
			var lsy1 = leading_start[1] + land_y
		
			tmp = lsx0
			lsx0 = min(tmp, lsx1)
			lsx1 = max(tmp, lsx1)
			tmp = lsy0
			lsy0 = min(tmp, lsy1)
			lsy1 = max(tmp, lsy1)
			
			lsx0 = min(lsx0, cur_lx0)
			lsy0 = min(lsy0, cur_ly0)
			lsx1 = max(lsx1, cur_lx1)
			lsy1 = max(lsy1, cur_ly1)
			
			if trace_draw_debug
			{
				draw_primitive_begin(pr_linestrip)
				draw_set_color(c_aqua)
				draw_set_alpha(175)
				draw_vertex(lsx0, lsy0)
				draw_vertex(lsx1, lsy0)
				draw_vertex(lsx1, lsy1)
				draw_vertex(lsx0, lsy1)
				draw_vertex(lsx0, lsy0)
				draw_primitive_end()
				
				draw_primitive_begin(pr_linestrip)
				draw_set_color(c_fuchsia)
				draw_set_alpha(175)
				draw_vertex(cur_lx0, cur_ly0)
				draw_vertex(cur_lx1, cur_ly0)
				draw_vertex(cur_lx1, cur_ly1)
				draw_vertex(cur_lx0, cur_ly1)
				draw_vertex(cur_lx0, cur_ly0)
				draw_primitive_end()
			}
			
			lsx0 = floor(lsx0+math_get_epsilon())
			lsy0 = floor(lsy0+math_get_epsilon())
			lsx1 = floor(lsx1+1-math_get_epsilon())
			lsy1 = floor(lsy1+1-math_get_epsilon())
		
			var ignore_x0 = min(trailing_total[0], leading_total[0])
			var ignore_y0 = min(trailing_total[1], leading_total[1])
			var ignore_x1 = max(leading_total[0], trailing_total[0])
			var ignore_y1 = max(leading_total[1], trailing_total[1])
			
			if trace_draw_debug
			{
				draw_primitive_begin(pr_linestrip)
				draw_set_color(c_aqua)
				draw_set_alpha(0.9)
				draw_vertex(lsx0, lsy0)
				draw_vertex(lsx1, lsy0)
				draw_vertex(lsx1, lsy1)
				draw_vertex(lsx0, lsy1)
				draw_vertex(lsx0, lsy0)
				draw_primitive_end()
			}
			
			var xcount = abs(lsx1-lsx0)
			var ycount = abs(lsy1-lsy0)
			
			for (xx = lsx0; --xcount >= 0; xx++)
			{
				var ignx = ignore_x0 <= xx and xx < ignore_x1
				yc = ycount
				for (yy = lsy0; --yc >= 0; yy++)
				{
					if ignx and ignore_y0 <= yy and yy < ignore_y1
					{
						continue
					}
					ddid |= _get_bloc_callback(xx, yy)
				}
			}
			if trace_nearest >= nearest
			{
				break
			}
			nearest = trace_nearest
		}
	}
	
	if trace_draw_debug
	{
		draw_set_color(c_red)
		draw_set_alpha(175)
		draw_primitive_begin(pr_linestrip)
		draw_vertex(leading_total[0], leading_total[1])
		draw_vertex(trailing_total[0], leading_total[1])
		draw_vertex(trailing_total[0], trailing_total[1])
		draw_vertex(leading_total[0], trailing_total[1])
		draw_vertex(leading_total[0], leading_total[1])
		draw_primitive_end()
	}
	return did
}

function trace (_get_bloc_callback)
{
	
	trace_reset()
	hit.reset()

	var ray_direction = vec_get_temp(
		ray.get_dir_x(),
		ray.get_dir_y()
	)
	
	var time_max = vec_sqr_length(ray_direction)
	
	if time_max <= 0
	{
		return false
	}
	
	var ray_origin = vec_get_temp(
		ray.x0(),
		ray.y0()
	)
	
	boxcast_context.setup(
		ray_origin[Vec.x],
		ray_origin[Vec.y],
		ray_direction[Vec.x],
		ray_direction[Vec.y],
	)
	
	
	
	var cel  = vec_get_temp()
	var step = vec_get_temp()
	var time_delta = vec_get_temp()
	
	var time_next  = vec_get_temp()
	var normal = vec_get_temp()
	
	time_max = sqrt(time_max)
	var ivt_t = 1 / time_max
	
	for (var i = 0; i < Vec.sizeof; i++)
	{
		var rd = ray_direction[i]
		var dir_positive = rd >= 0
		
		var ro = ray_origin[i]
		
		step[i] = dir_positive ? +1 : -1
		cel[i] = floor(ro)
		time_delta[i] = rd == 0 ? infinity : abs(1.0 / rd)
		
		time_next[i] = dir_positive
			? (cel[i] + 1 - ro)
			: (ro - cel[i])
		time_next[i] *= time_delta[i]
		
		normal[i] = rd * ivt_t
		
	}
	
	var axis = -1

	var maxiter = calc_iter_count(ray_origin, ray_direction)
	var time = 0
	var cel_x, cel_y
	var pev_x = -step[Vec.x] * infinity
	var pev_y = -step[Vec.y] * infinity
	
	// line goes upwards or would draw a line of cels that is entirely horizontal
	var downsearch_prereq = step[Vec.y] >= 0 or cel[Vec.y] == floor(ray_origin[Vec.y] + ray_direction[Vec.y])
	
	while (--maxiter) >= 0
	{
		cel_x = cel[Vec.x]
		cel_y = cel[Vec.y]
		
		var pev_axis = axis
		axis = time_next[Vec.x] < time_next[Vec.y] ? Vec.x : Vec.y
		
		var down_search
		if downsearch_prereq
		{
			down_search = cel_x <> pev_x
		}
		else
		{
			down_search = (
				maxiter == 0 or
				(axis == Vec.x and (cel_x <> pev_x or (pev_axis == Vec.y and cel_y < pev_y)))
			)
		}
		
		var did = _get_bloc_callback(cel_x, cel_y)
		
		var did_down = TRACE_FALSE
		if down_search and (did & TRACE_CEL_CONTAINED_COLLIDERS) == 0
		{
			did_down = _get_bloc_callback(cel_x, cel_y - 1)
		}
		
		if ((did | did_down) & TRACE_COLLIDED) <> 0
		{
			return true
		}
		
		pev_x = cel_x
		pev_y = cel_y
		time = time_next[axis]
		time_next[axis] += time_delta[axis]
		cel[axis] += step[axis]

	}
	
	return false
}


cam = new Camera()
m_view = matrix_build_identity()
m_proj = matrix_build_identity()

function trace_reset ()
{
	trace_nearest = infinity
	trace_any = false
	trace_continue_count = -1
}
trace_any = false
trace_nearest = infinity
trace_nearest_box = rect_create()
trace_nearest_normal = vec_create()
trace_continue_count = -1
trace_draw_debug = false

trace_predicate = function (_x, _y) {
	static COLLIDERS = ds_list_create()
	ds_list_clear(COLLIDERS)
	
	var type = map.get(_x, _y)
	var cc = type.get_colliders(map, _x, _y, COLLIDERS)
	if cc <= 0
	{
		if trace_continue_count > -1
		{
			--trace_continue_count
			if trace_continue_count == -1
			{
				return TRACE_COLLIDED
			}
		}
		
		return TRACE_FALSE
	}
	var any = false
	var temp_rect = rect_get_temp()
	for (var i = cc; --i >= 0;)
	{
		var collider = rect_set_from(temp_rect, COLLIDERS[| i])
		var taller = rect_y1(collider) > 1
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
			if tt < trace_nearest
			{
				if taller and trace_continue_count == -1
				{
					trace_continue_count = 1
				}
				any = true
				trace_nearest = tt
				rect_set_from(trace_nearest_box, collider)
				vec_set_xy(trace_nearest_normal, boxcast_context.normal_x, boxcast_context.normal_y)
			}
		}
	}
	trace_any |= any
	
	if any and trace_continue_count > 0
	{
		trace_continue_count -= 1
		return TRACE_CEL_CONTAINED_COLLIDERS
	}
	
	if trace_continue_count == 0
	{
		return TRACE_CEL_CONTAINED_COLLIDERS | TRACE_COLLIDED
	}
	
	return TRACE_CEL_CONTAINED_COLLIDERS | (TRACE_COLLIDED * any)
}

trace_predicate2 = function (_x, _y) {
	static COLLIDERS = ds_list_create()
	ds_list_clear(COLLIDERS)
	
	var type = map.get(_x, _y)
	var cc = type.get_colliders(map, _x, _y, COLLIDERS)
	if cc <= 0
	{
		return false
	}
	var any = false
	var temp_rect = rect_get_temp()
	for (var i = cc; --i >= 0;)
	{
		var collider = rect_set_from(temp_rect, COLLIDERS[| i])
		var taller = rect_y1(collider) > 1
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
			if tt < trace_nearest
			{
				any = true
				trace_any = true
				trace_nearest = tt
				rect_set_from(trace_nearest_box, collider)
				vec_set_xy(trace_nearest_normal, boxcast_context.normal_x, boxcast_context.normal_y)
			}
		}
	}

	return any
}

#region setup

var bbw = (0.6) * 0.5
var bbh = 1.8

//var bbw = (4.) * 0.5
//var bbh = .1
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
	"  _         |  #",
	"| |     T | |  #",
	"###     #####  #",
	"#              #",
	"#              #",
	"##C     O   O  #",
	"# T     #   #  #",
	"###O     ###   #",
	"#    S         #",
	"################",
)
cam.x = map.wide / 2
cam.y = map.tall / 2

trace_predicate  = method(self, trace_predicate)
trace_predicate2 = method(self, trace_predicate2)

#endregion

