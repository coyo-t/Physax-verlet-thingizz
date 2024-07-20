

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
			var rxd = x1-x0
			var ryd = y1-y0
			x0 = _x + 0.5
			y0 = _y + 0.5
			x1 = x0+rxd
			y1 = y0+ryd
		}
	})
	
	REG("O", function (_x, _y) {
		map.fast_set(_x, _y, ID_POLE)
	})
	
	REG("C", function (_x, _y) {
		map.fast_set(_x, _y, ID_CHECKER)
	})
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
		return 0 <= _x and _x < wide and 0 <= _y and _y < tall
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
	create: function ()
	{
		var map_wide = string_length(argument[0])
		var map_tall = argument_count
		
		resize(map_wide, map_tall)
		
		ds_grid_clear(data, other.ID_NON.numeric)
		
		for (var yy = map_tall; --yy >= 0;)
		{
			for (var xx = map_wide; --xx >= 0;)
			{
				var cel = string_char_at(argument[yy], xx+1)
				
				if struct_exists(other.PROCEDURES, cel)
				{
					struct_get(other.PROCEDURES, cel)(xx, yy)
				}
			}
		}
	}
end

ray = begin
	x0:0,
	y0:0,
	x1:1,
	y1:0,
	
	///@self
	get_dir_x: function ()
	{
		return x1 - x0
	},
	
	///@self
	get_dir_y: function ()
	{
		return y1 - y0
	},
end

hit = begin
	did: false,
	x: 0,
	y: 0,
	points: ds_list_create(),
	cels: ds_list_create(),
	///@self
	reset: function ()
	{
		time = 1
		did = false
		ds_list_clear(points)
		ds_list_clear(cels)
	},
	///@self
	set_co_from_last_point: function ()
	{
		var c = points[| ds_list_size(points)-1]
		x = c[Vec.x]
		y = c[Vec.y]
	},
	time: 1,
end

mouse = begin
	x: 0,
	y: 0,
	map_x: 0,
	map_y: 0,
end

boxcast_context = new RayRectContext()

///@self
function trace (_get_bloc_callback)
{
	hit.reset()
	boxcast_context.setup_endpoints(ray.x0, ray.y0, ray.x1, ray.y1)
	
	var ray_x = ray.x0
	var ray_y = ray.y0
	var ray_xd = ray.get_dir_x()
	var ray_yd = ray.get_dir_y()
	
	var time_max = power(ray_xd, 2) + power(ray_yd, 2)
	
	if time_max <= 0
	{
		return 1
	}
	
	time_max = sqrt(time_max)
	
	var cel_x = floor(ray_x)
	var cel_y = floor(ray_y)
	
	var xdp = ray_xd >= 0
	var ydp = ray_yd >= 0
	
	var step_x = xdp ? +1 : -1
	var step_y = ydp ? +1 : -1
	
	var delta_dist_x = ray_xd == 0 ? infinity : abs(1 / ray_xd)
	var delta_dist_y = ray_yd == 0 ? infinity : abs(1 / ray_yd)
	
	var side_dist_x = (xdp ? (cel_x + 1 - ray_x) : (ray_x - cel_x)) * delta_dist_x
	var side_dist_y = (ydp ? (cel_y + 1 - ray_y) : (ray_y - cel_y)) * delta_dist_y
	
	var normal_x = ray_xd / time_max
	var normal_y = ray_yd / time_max
	
	var axis = Vec.x
	var time = 0
	while time < 1
	{
		ds_list_add(hit.points, vec_create(ray_x+ray_xd*time, ray_y+ray_yd*time))
		ds_list_add(hit.cels, vec_create(cel_x, cel_y))
		if _get_bloc_callback(cel_x, cel_y)
		{
			//hit.did = true
			return true
		}
		
		if side_dist_x < side_dist_y
		{
			time = side_dist_x
			side_dist_x += delta_dist_x
			cel_x += step_x
			axis = Vec.x
		}
		else
		{
			time = side_dist_y
			side_dist_y += delta_dist_y
			cel_y += step_y
			axis = Vec.y
		}
		
	}
	//hit.set_co_from_last_point()
	return false
}


map.create(
	"########",
	"#      #",
	"#   P  #",
	"##C    #",
	"#      #",
	"# #O O #",
	"#    # #",
	"########",
)
