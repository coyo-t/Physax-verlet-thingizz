

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
	time_delta/*Vec*/ = vec_create()
	time_next/*Vec*/ = vec_create()
	
	axis/*Int*/ = Vec.x
	
	iterations/*Int*/ = 0
	
	static set_box = function (_box/*Rect*/)
	{
		rect_set_from(box_original, _box)
		vec_set_from(box_min, rect_get_min_corner(_box))
		vec_set_from(box_max, rect_get_max_corner(_box))
		// this is to account for blocs such as fences, which have a hitbox
		// that extends above their grid cell. Technically, only need to subtract
		// 0.5, since fences (and fence-likes) afaicr are the only blocs that do this
		// but its good to future proof v_v
		//box_min[Vec.y] -= 1
	}
	
	static run = function ()/*Value*/
	{
		iterations = 0
		time = 0.0
		time_max = 0.0
		vec_set_xy(time_delta, 0,0)
		vec_set_xy(time_next, 0,0)
		
		// init for the current sweep vector and take first step
		init_sweep()
		if time_max <= 0
		{
			return 0
		}
		
		// TODO: initial state of leading/trailing indices is cast backwards
		
		draw_arrow(
			leading_corner[Vec.x]-1,
			leading_corner[Vec.y]-1,
			leading_corner[Vec.x]+direction[Vec.x]*time-1,
			leading_corner[Vec.y]+direction[Vec.y]*time-1,
			3/16
		)
		
		axis = lesser_axis()
		axis = advance_step()
		
		// loop along raycast vector
		//while time <= min(time_max, hard_time_limit_s)
		while time <= time_max
		{
			// sweeps over leading face of AABB
			if check_collide(axis)
			{
				// calls the callback and decides whether to continue
				var done = on_collide()
				if done
				{
					return
					//return time_accumulator
				}
			}
			iterations++
			axis = advance_step()
			
			//if iterations == 2
			//{
			//	break
			//}
			
		}
	}
	
	static init_sweep = function ()
	{
		// parametrization t along raycast
		time = 0.0
		time_max = vec_sqr_length(direction)
		if time_max <= 0
		{
			return
		}
		time_max = sqrt(time_max)
		for (var i = 0; i < Vec.sizeof; i++)
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
		var naxis = lesser_axis()

		var dt = time_next[naxis] - time
		time = time_next[naxis]

		leading_indices[naxis] += step[naxis]
		
		time_next[naxis] += time_delta[naxis]
		
		for (var i = 0; i < Vec.sizeof; i++)
		{
			leading_corner[i] += normalized[i] * dt
			trailing_corner[i] += normalized[i] * dt
			trailing_indices[i] = trailing_edge_to_int(trailing_corner[i], step[i])
		}
		
		return naxis
	}
	
	// check for collisions - iterate over the leading face on the advancing axis
	static check_collide = function (i_axis/*Int*/)/*Boolean*/
	{
		static pev_x0 = 0
		static pev_y0 = 0
		static pev_c = 0
		
		begin
			draw_primitive_begin(pr_linestrip)
			draw_set_color(c_orange)
			draw_set_alpha(0.5)
			draw_vertex(trailing_corner[0], trailing_corner[1])
			draw_vertex(leading_corner[0],  trailing_corner[1])
			draw_vertex(leading_corner[0],  leading_corner[1])
			draw_vertex(trailing_corner[0], leading_corner[1])
			draw_vertex(trailing_corner[0], trailing_corner[1])
			draw_primitive_end()
			draw_set_alpha(1.0)
		
			draw_primitive_begin(pr_trianglefan)
			draw_set_color(c_orange)
			draw_set_alpha(0.5)
			var juandeeg = 1/16
			var juandeez = 1-juandeeg
			draw_vertex(leading_indices[0]+juandeeg, leading_indices[1]+juandeeg)
			draw_vertex(leading_indices[0]+juandeez, leading_indices[1]+juandeeg)
			draw_vertex(leading_indices[0]+juandeez, leading_indices[1]+juandeez)
			draw_vertex(leading_indices[0]+juandeeg, leading_indices[1]+juandeez)
			draw_primitive_end()
			draw_set_alpha(1.0)
		
			draw_set_color(c_lime)
			draw_set_alpha(0.5)
			draw_arrow(
				leading_corner[0]-1, leading_corner[1]-1,
				leading_indices[0]-1+0.5, leading_indices[1]-1+0.5,
				1/16
			)
			draw_set_alpha(1.)
		end
		
		var stepx = step[Vec.x]
		var stepy = step[Vec.y]

		//var x0 = i_axis == Vec.x ? leading_indices[Vec.x] : trailing_indices[Vec.x]
		//var y0 = i_axis == Vec.y ? leading_indices[Vec.y] : trailing_indices[Vec.y]

		var x0, y0
		if i_axis == Vec.x
		{
			x0 = leading_indices[Vec.x]
			y0 = trailing_indices[Vec.y]
		}
		else if i_axis == Vec.y
		{
			x0 = trailing_indices[Vec.x]
			y0 = leading_indices[Vec.y]
		}

		var x1 = leading_indices[Vec.x] + step[Vec.x]
		var y1 = leading_indices[Vec.y] + step[Vec.y]
		
		var xcount = abs(x1-x0)
		var ycount = abs(y1-y0)
		
		begin // draw debug
			if iterations <> 0 and pev_x0 == x0 and pev_y0 == y0
			{
				pev_c++
			}
			else
			{
				pev_c = 0
			}
			
			var m0 = 0.1
			var m1 = 1-m0
			var xx0 = x0
			var yy0 = y0
			
			var xx1 = leading_indices[0]
			var yy1 = leading_indices[1]

			draw_set_color(c_aqua)
			draw_set_alpha(0.5)
			draw_arrow(xx0-1+0.5, yy0-1+0.5, xx1-1+0.5, yy1-1+0.5, 4/16)
			var tmp = xx0
			xx0 = min(xx0, xx1)
			xx1 = max(tmp, xx1)
			tmp = yy0
			yy0 = min(yy0, yy1)
			yy1 = max(tmp, yy1)
			
			xx0 += m0
			yy0 += m0
			xx1 += m1
			yy1 += m1
			
			draw_set_color(c_yellow)
			draw_primitive_begin(pr_linestrip)
			draw_vertex(xx0, yy0)
			draw_vertex(xx1, yy0)
			draw_vertex(xx1, yy1)
			draw_vertex(xx0, yy1)
			draw_vertex(xx0, yy0)
			draw_primitive_end()
			
			draw_set_color(c_white)
			draw_set_alpha(0.5)
			draw_set_halign(fa_center)
			
			draw_text_in_world((xx0+xx1)*0.5, (yy0+yy1)*0.5+pev_c*0.25, $"{iterations}", 0.5)
			draw_set_halign(fa_left)
			draw_set_alpha(1)
			
			pev_x0 = x0
			pev_y0 = y0
		end
		
		var yc, yy
		for (var xx = x0; --xcount >= 0; xx+=stepx)
		{
			yc = ycount
			for (yy = y0; --yc >= 0; yy+=stepy)
			{
				if callback_get_voxel(xx, yy)
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
		var dir = step[axis]

		// vector moved so far, and left to move
		var done = time / time_max
		
		for (var i = 0; i < Vec.sizeof; i++)
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
		var res = callback_on_collision(1, axis, dir, remaining)
		//var res = callback_on_collision(time_accumulator, axis, dir, remaining)

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
	
	static lesser_axis = function ()
	{
		return time_next[Vec.x] < time_next[Vec.y] ? Vec.x : Vec.y
	}
	
	static sweep = function ()
	{
		run()
	}
end
