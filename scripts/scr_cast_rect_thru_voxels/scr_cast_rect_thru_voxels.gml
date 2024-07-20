

// https://github.com/fenomas/voxel-aabb-sweep/blob/master/index.js
// consider algo as a raycast along the AABB's leading corner
// as raycast enters each new voxel, iterate in 2D over the AABB's 
// leading face in that axis looking for collisions
// 
// original raycast implementation: https://github.com/fenomas/fast-voxel-raycast
// original raycast paper: http://www.cse.chalmers.se/edu/year/2010/course/TDA361/grid.pdf

/*
typealias GetVoxelCallback = (x:Int, y:Int) -> Boolean
typealias OnCollisionCallback = (distance:Value, axis:Int, direction:Vec, remaining:Vec) -> Boolean
*/

function RectVoxelSweeper (
	box/*Rect*/,
	dir/*Vec*/,
	get_voxel_callback/*GetVoxelCallback*/,
	on_collision_callback/*OnCollisionCallback*/
)
constructor begin
	
	static DEBUG_RECT = rect_create(0,0,0,0)
	
	callback_get_voxel/*GetVoxelCallback*/ = get_voxel_callback
	callback_on_collision/*OnCollisionCallback*/ = on_collision_callback
	
	result/*Vec*/ = vec_create()
	
	box_original/*Rect*/ = rect_copy(box)
	box_min/*Vec*/ = rect_get_min_corner(box)
	box_max/*Vec*/ = rect_get_max_corner(box)
	
	direction/*Vec*/ = vec_copy(dir)
	
	step/*Vec*/ = vec_create()
	normalized/*Vec*/ = vec_create()
	
	leading_corner/*Vec*/ = vec_create()
	leading_indices/*Vec*/ = vec_create()
	trailing_corner/*Vec*/ = vec_create()
	trailing_indices/*Vec*/ = vec_create()
	
	time/*Value*/ = 0.0
	time_max/*Value*/ = 0.0
	time_accumulator/*Value*/ = 0.0
	time_delta/*Vec*/ = vec_create()
	time_next/*Vec*/ = vec_create()
	
	axis/*Int*/ = 0
	
	hard_time_limit/*Value*/ = infinity
	hard_time_limit_s/*Value*/ = infinity
	
	adds_steps/*Int*/ = 2
	
	static set_hard_time_limit = function (_v/*Value*/)
	{
		set_hard_time_limit_sqr(_v*_v)
	}
	
	static set_hard_time_limit_sqr = function (_v/*Value*/)
	{
		hard_time_limit = _v
		hard_time_limit_s = sqrt(_v)
	}
	
	static set_box = function (_box/*Rect*/)
	{
		rect_set_from(box_original, _box)
		vec_set_from(box_min, rect_get_min_corner(_box))
		vec_set_from(box_max, rect_get_max_corner(_box))
	}
	
	static run = function ()/*Value*/
	{
		time = 0.0
		time_max = 0.0
		time_accumulator = 0.0
		var extra_steps = adds_steps
		vec_set_xy(time_delta, 0,0)
		vec_set_xy(time_next, 0,0)
		
		// init for the current sweep vector and take first step
		init_sweep()
		if time_max <= 0
		{
			return 0
		}

		axis = advance_step()

		// loop along raycast vector
		while time <= min(time_max, hard_time_limit_s)
		{
			// sweeps over leading face of AABB
			if check_collide(axis)
			{
				// calls the callback and decides whether to continue
				var done = on_collide()
				if done
				{
					//--extra_steps
					//if extra_steps < 0
					{
						return time_accumulator
					}
				}
			}
			axis = advance_step()
		}

		// reached the end of the vector unobstructed, finish and exit
		time_accumulator += time_max
		
		vec_add_vec(box_min, direction)
		vec_add_vec(box_max, direction)

		return time_accumulator
	}
	
	static init_sweep = function ()
	{
		// parametrization t along raycast
		time = 0.0
		
		time_max = min(hard_time_limit, vec_sqr_length(direction))
		if time_max <= 0
		{
			return
		}
		time_max = sqrt(time_max)
		for (var i = 0; i < 2; i++)
		{
			var dir = direction[i] >= 0
			step[i] = dir ? 1 : -1
			// trailing / trailing edge coords
			leading_corner[i] = dir ? box_max[i] : box_min[i]
			trailing_corner[i] = dir ? box_min[i] : box_max[i]
			// int values of lead/trail edges
			leading_indices[i] = leading_edge_to_int(leading_corner[i], step[i])
			trailing_indices[i] = trailing_edge_to_int(trailing_corner[i], step[i])
			
			normalized[i] = direction[i] / time_max
			// distance along t required to move one voxel in each axis
			time_delta[i] = normalized[i] == 0 ? infinity : abs(1 / normalized[i])
			// location of nearest voxel boundary, in units of t 
			var dist = dir ? (leading_indices[i] + 1 - leading_corner[i]) : (leading_corner[i] - leading_indices[i])
			time_next[i] = (time_delta[i] < infinity) ? time_delta[i] * dist : infinity
		}
	}
	
	// advance to next voxel boundary, and return which axis was stepped
	static advance_step = function ()/*Int*/
	{
		var naxis = time_next[0] < time_next[1] ? 0 : 1
		
		var dt = time_next[naxis] - time
		time = time_next[naxis]
		leading_indices[naxis] += step[naxis]
		time_next[naxis] += time_delta[naxis]
		for (var i = 0; i < 2; i++)
		{
			trailing_corner[i] += dt * normalized[i]
			trailing_indices[i] = trailing_edge_to_int(trailing_corner[i], step[i])
		}

		return naxis
	}
	
	// check for collisions - iterate over the leading face on the advancing axis
	static check_collide = function (i_axis/*Int*/)/*Boolean*/
	{
		var stepx = step[0]
		var x0 = (i_axis == 0) ? leading_indices[0] : trailing_indices[0]
		var x1 = leading_indices[0] + stepx
		var stepy = step[1]
		var y0 = (i_axis == 1) ? leading_indices[1] : trailing_indices[1]
		var y1 = leading_indices[1] + stepy
		
		draw_primitive_begin(pr_linestrip)
		draw_vertex_colour(x0, y0, c_aqua, 0.5)
		draw_vertex_colour(x1, y0, c_aqua, 0.5)
		draw_vertex_colour(x1, y1, c_aqua, 0.5)
		draw_vertex_colour(x0, y1, c_aqua, 0.5)
		draw_vertex_colour(x0, y0, c_aqua, 0.5)
		draw_primitive_end()
		
		var xcount = abs(x1-x0)
		var ycount = abs(y1-y0)
		for (var xx = x0; --xcount >= 0; xx += stepx)
		{
			var yc = ycount
			for (var yy = y0; --yc >= 0; yy += stepy)
			{
				draw_primitive_begin(pr_trianglefan)
				var ch = ((xx^yy)&1) <> 0
				var c = ch ? c_teal : c_aqua
				var a = ch ? 0.5 : 0.1
				draw_vertex_colour(xx, yy, c, a)
				draw_vertex_colour(xx+1, yy, c, a)
				draw_vertex_colour(xx+1, yy+1, c, a)
				draw_vertex_colour(xx, yy+1, c, a)
				draw_primitive_end()
				if callback_get_voxel(xx, yy) or callback_get_voxel(xx, yy-1)
				{
					return true
				}
			}
		}
		return false
	}
	
	// on collision - call the callback and return or set up for the next sweep
	static on_collide = function ()/*Boolean*/
	{
		static remaining/*Vec*/ = vec_create()
		// set up for callback
		time_accumulator += time
		var dir = step[axis]

		// vector moved so far, and left to move
		var done = time / time_max

		for (var i = 0; i < 2; i++)
		{
			var dv = direction[i] * done
			box_min[i] += dv
			box_max[i] += dv
			remaining[i] = direction[i] - dv
		}

		// set leading edge of stepped axis exactly to voxel boundary
		// else we'll sometimes rounding error beyond it
		var to_set = dir > 0 ? box_max : box_min
		to_set[axis] = floor(to_set[axis] + 0.5)

		// call back to let client update the "left to go" vector
		var res = callback_on_collision(time_accumulator, axis, dir, remaining)

		// bail out out on truthy response
		if res
		{
			return true
		}

		// init for new sweep along vec
		
		vec_set_from(direction, remaining)
		init_sweep()
		return time_max <= 0
	}
	
	static leading_edge_to_int = function(coord/*Value*/, step/*Int*/)/*Int*/
	{
		return floor(coord - step * math_get_epsilon())
	}
	
	static trailing_edge_to_int = function (coord/*Value*/, step/*Int*/)/*Int*/
	{
		return floor(coord + step * math_get_epsilon())
	}
	
	static sweep = function (dont_translate/*Boolean*/=false)/*Number*/
	// (getVoxel, box, direction, callback, noTranslate)
	{
		// run sweep implementation
		var dist = run()
		
		// translate box by distance needed to updated base value
		//if not dont_translate
		//{
		//	for (var i = 0; i < 2; i++)
		//	{
		//		result[i] = (direction[i] > 0) ? maxx[i] - box.max[i] : base[i] - box.base[i]
		//	}
		//	box.translate(result)
		//}
		
		// return value is total distance moved (not necessarily magnitude of [end]-[start])
		return dist
	}
end
