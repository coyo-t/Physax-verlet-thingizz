
//!#import vec.* in Vec

// https://github.com/fenomas/voxel-aabb-sweep/blob/master/index.js
// consider algo as a raycast along the AABB's leading corner
// as raycast enters each new voxel, iterate in 2D over the AABB's 
// leading face in that axis looking for collisions
// 
// original raycast implementation: https://github.com/fenomas/fast-voxel-raycast
// original raycast paper: http://www.cse.chalmers.se/edu/year/2010/course/TDA361/grid.pdf

/*typealias GetVoxelCallback = (x:Int, y:Int) -> Boolean*/
/*typealias OnCollisionCallback = (distance:Number, axis:Int, direction:Vec, remaining:Vec) -> Boolean*/


function RectVoxelSweeper (
	box/*:Rect*/,
	dir/*:Vec*/,
	get_voxel_callback/*:GetVoxelCallback*/,
	on_collision_callback/*:OnCollisionCallback*/
)
constructor begin
	
	callback_get_voxel/*:GetVoxelCallback*/ = get_voxel_callback
	callback_on_collision/*:OnCollisionCallback*/ = on_collision_callback
	
	result/*:Vec*/ = vec_create()
	
	box_min/*:Vec*/ = rect_get_min_corner(box)
	box_max/*:Vec*/ = rect_get_max_corner(box)
	
	direction/*:Vec*/ = vec_copy(dir)
	
	step/*:Vec*/ = vec_create()
	normalized/*:Vec*/ = vec_create()
	
	leading_corner/*:Vec*/ = vec_create()
	leading_indices/*:Vec*/ = vec_create()
	trailing_corner/*:Vec*/ = vec_create()
	trailing_indices/*:Vec*/ = vec_create()
	
	time/*:Number*/ = 0.0
	time_max/*:Number*/ = 0.0
	time_accumulator/*:Number*/ = 0.0
	time_delta/*:Vec*/ = vec_create()
	time_next/*:Vec*/ = vec_create()
	
	axis/*:Int*/ = 0
	
	static set_box = function (_box/*:Rect*/)
	{
		box_min = rect_get_min_corner(_box)
		box_max = rect_get_max_corner(_box)
	}
	
	static run = function () /*-> Number*/
	{
		// init for the current sweep vector and take first step
		init_sweep()
		if time_max == 0
		{
			return 0
		}

		axis = advance_step()

		// loop along raycast vector
		while time <= time_max
		{
			// sweeps over leading face of AABB
			if check_collide(axis)
			{
				// calls the callback and decides whether to continue
				var done = on_collide()
				if done
				{
					return time_accumulator
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
		
		time_max = vec_sqr_length(direction)
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
			var lead = dir ? box_max[i] : box_min[i]
			trailing_corner[i] = dir ? box_min[i] : box_max[i]
			// int values of lead/trail edges
			leading_indices[i] = lead_edge_to_int(lead, step[i])
			trailing_indices[i] = trail_edge_to_int(trailing_corner[i], step[i])
			
			normalized[i] = direction[i] / time_max
			// distance along t required to move one voxel in each axis
			time_delta[i] = abs(1 / normalized[i])
			// location of nearest voxel boundary, in units of t 
			var dist = dir ? (leading_indices[i] + 1 - lead) : (lead - leading_indices[i])
			tNext[i] = (time_delta[i] < infinity) ? time_delta[i] * dist : infinity
		}
	}
	
	// advance to next voxel boundary, and return which axis was stepped
	static advance_step = function () /*-> Int*/
	{
		var axis = time_next[Vec.x] < time_next[Vec.y] ? Vec.x : Vec.y
		
		var dt = time_next[axis] - time
		time = time_next[axis]
		leading_corner[axis] += step[axis]
		time_next[axis] += time_delta[axis]
		for (var i = 0; i < 2; i++)
		{
			trailing_corner[i] += dt * normalized[i]
			trailing_indices[i] = trail_edge_to_int(trailing_corner[i], step[i])
		}

		return axis
	}
	
	// check for collisions - iterate over the leading face on the advancing axis
	static check_collide = function (i_axis/*:Int*/) /*-> Boolean*/
	{
		var stepx = step[Vec.x]
		var x0 = (i_axis == Vec.x) ? leading_indices[Vec.x] : trailing_indices[Vec.x]
		var x1 = leading_indices[Vec.x] + stepx

		var stepy = step[Vec.y]
		var y0 = (i_axis == Vec.y) ? leading_indices[Vec.y] : trailing_indices[Vec.y]
		var y1 = leading_indices[Vec.y] + stepy

		for (var xx = x0; xx <> x1; xx += stepx)
		{
			for (var yy = y0; yy <> y1; yy += stepy)
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
	static on_collide = function () /*-> Boolean*/
	{
		static remaining/*:Vec*/ = vec_create()
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
		if (dir > 0)
		{
			box_max[axis] = floor(box_max[axis] + 0.5)
		}
		else
		{
			box_min[axis] = floor(box_min[axis] + 0.5)
		}

		// call back to let client update the "left to go" vector
		var res = callback_on_collision(time_accumulator, axis, dir, remaining)

		// bail out out on truthy response
		if (res)
		{
			return true
		}

		// init for new sweep along vec
		
		vec_add_vec(direction, remaining)
		init_sweep()
		return max_t == 0
	}
	
	static leading_edge_to_int = function(coord/*:Number*/, step/*:Number*/) /*-> Int*/
	{
		return floor(coord - step * EPS)
	}
	
	static trailing_edge_to_int = function (coord/*:Number*/, step/*:Number*/) /*-> Int*/
	{
		return floor(coord + step * EPS)
	}
	
	static sweep = function (dont_translate/*:Boolean*/=false) /*->Number*/
	// (getVoxel, box, direction, callback, noTranslate)
	{
		var vec = vec_arr
		var base = base_arr
		var maxx = max_arr
		var result = result_arr
		
		// init parameter float arrays
		//for (var i = 0; i < 2; i++)
		//{
		//	vec[i]  = direction[i]
		//	maxx[i] = box.max[i]
		//	base[i] = box.base[i]
		//}
		
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

function RVS (
	getVoxel,
	callback,
	rect/*:Rect*/,
	vec/*:Vec*/,
	maxx/*:Vec*/
) constructor begin

	//self.base = vec_create(rect_get_x0(rect), rect_get_y0(rect))
	//self.maxx = vec_create(rect_get_x1(rect), rect_get_y1(rect))
	self.box_min = rect_get_min_corner(rect)
	self.box_max = rect_get_max_corner(rect)
	self.callback = callback;
	self.getVoxel = getVoxel;
	self.vec = vec;
	
	
	tr = vec_create()
	ldi = vec_create()
	tri = vec_create()
	step = vec_create()
	
	tDelta = vec_create()
	tNext = vec_create()
	normed = vec_create()
	cumulative_t = 0.0
	t = 0.0
	
	max_t = 0.0
	
	axis = 0
	
	static run = function () /*-> number*/
	{
		// init for the current sweep vector and take first step
		initSweep()
		if max_t == 0
		{
			return 0
		}

		axis = stepForward()

		// loop along raycast vector
		while t <= max_t
		{
			// sweeps over leading face of AABB
			if checkCollision(axis)
			{
				// calls the callback and decides whether to continue
				var done = handleCollision()
				if done
				{
					return cumulative_t
				}
			}
			axis = stepForward()
		}

		// reached the end of the vector unobstructed, finish and exit
		cumulative_t += max_t
		
		vec_add_vec(box_min, vec)
		vec_add_vec(box_max, vec)

		return cumulative_t
	}

	// low-level implementations of each step:
	static initSweep = function ()
	{
		// parametrization t along raycast
		t = 0.0
		
		max_t = vec_sqr_length(vec)
		if max_t <= 0
		{
			return
		}
		max_t = sqrt(max_t)
		for (var i = 0; i < 2; i++)
		{
			var dir = vec[i] >= 0
			step[i] = dir ? 1 : -1
			// trailing / trailing edge coords
			var lead = dir ? box_max[i] : box_min[i]
			tr[i] = dir ? box_min[i] : box_max[i]
			// int values of lead/trail edges
			ldi[i] = lead_edge_to_int(lead, step[i])
			tri[i] = trail_edge_to_int(tr[i], step[i])
			// normed vector
			normed[i] = vec[i] / max_t
			// distance along t required to move one voxel in each axis
			tDelta[i] = abs(1 / normed[i])
			// location of nearest voxel boundary, in units of t 
			var dist = dir ? (ldi[i] + 1 - lead) : (lead - ldi[i])
			tNext[i] = (tDelta[i] < infinity) ? tDelta[i] * dist : infinity
		}
	}


	// check for collisions - iterate over the leading face on the advancing axis
	static checkCollision = function (i_axis/*:int*/) /*-> bool*/
	{
		var stepx = step[Vec.x]
		var x0 = (i_axis == Vec.x) ? ldi[Vec.x] : tri[Vec.x]
		var x1 = ldi[Vec.x] + stepx

		var stepy = step[Vec.y]
		var y0 = (i_axis == Vec.y) ? ldi[Vec.y] : tri[Vec.y]
		var y1 = ldi[Vec.y] + stepy

		for (var xx = x0; xx <> x1; xx += stepx)
		{
			for (var yy = y0; yy <> y1; yy += stepy)
			{
				if getVoxel(xx, yy)
				{
					return true
				}
			}
		}
		return false
	}


	// on collision - call the callback and return or set up for the next sweep
	static handleCollision = function () /*-> bool*/
	{
		static remaining = [0,0] ///@is {array<Vec>}
		// set up for callback
		cumulative_t += t
		var dir = step[axis]

		// vector moved so far, and left to move
		var done = t / max_t

		for (var i = 0; i < 2; i++)
		{
			var dv = vec[i] * done
			box_min[i] += dv
			box_max[i] += dv
			remaining[i] = vec[i] - dv
		}

		// set leading edge of stepped axis exactly to voxel boundary
		// else we'll sometimes rounding error beyond it
		if (dir > 0)
		{
			box_max[axis] = floor(box_max[axis] + 0.5)
		}
		else
		{
			box_min[axis] = floor(box_min[axis] + 0.5)
		}

		// call back to let client update the "left to go" vector
		var res = callback(cumulative_t, axis, dir, remaining)

		// bail out out on truthy response
		if (res)
		{
			return true
		}

		// init for new sweep along vec
		
		vec_add_vec(vec, remaining)
		initSweep()
		return max_t == 0
	}


	// advance to next voxel boundary, and return which axis was stepped
	static stepForward = function () /*-> int*/
	{
		var axis = tNext[Vec.x] < tNext[Vec.y] ? Vec.x : Vec.y
		
		var dt = tNext[axis] - t
		t = tNext[axis]
		ldi[axis] += step[axis]
		tNext[axis] += tDelta[axis]
		for (var i = 0; i < 2; i++)
		{
			tr[i] += dt * normed[i]
			tri[i] = trail_edge_to_int(tr[i], step[i])
		}

		return axis
	}

	static lead_edge_to_int = function(coord/*:number*/, step/*:number*/) /*-> int*/
	{
		return floor(coord - step * EPS)
	}
	static trail_edge_to_int = function (coord/*:number*/, step/*:number*/) /*-> int*/
	{
		return floor(coord + step * EPS)
	}
	
	
	static sweep = function (getVoxel, box, direction, callback, noTranslate, epsilon)
	{
		var vec = vec_arr
		var base = base_arr
		var maxx = max_arr
		var result = result_arr
		
		// init parameter float arrays
		for (var i = 0; i < 2; i++)
		{
			vec[i]  = direction[i]
			maxx[i] = box.max[i]
			base[i] = box.base[i]
		}
		
		// run sweep implementation
		var dist = sweep_impl(getVoxel, callback, vec, base, max)
		
		// translate box by distance needed to updated base value
		if not noTranslate
		{
			for (var i = 0; i < 2; i++)
			{
				result[i] = (direction[i] > 0) ? maxx[i] - box.max[i] : base[i] - box.base[i]
			}
			box.translate(result)
		}
		
		// return value is total distance moved (not necessarily magnitude of [end]-[start])
		return dist
	}
end

