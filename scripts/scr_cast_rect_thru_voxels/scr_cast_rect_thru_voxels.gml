
function RectVoxelSweeper (getVoxel, callback, vec, base, maxx) constructor begin

	self.maxx = maxx

	// consider algo as a raycast along the AABB's leading corner
	// as raycast enters each new voxel, iterate in 2D over the AABB's 
	// leading face in that axis looking for collisions
	// 
	// original raycast implementation: https://github.com/fenomas/fast-voxel-raycast
	// original raycast paper: http://www.cse.chalmers.se/edu/year/2010/course/TDA361/grid.pdf
	
	self.callback = callback
	self.getVoxel = getVoxel
	self.vec = vec
	self.base = base
	
	self.tr = []
	self.ldi = []
	self.tri = []
	self.step = []
	self.tDelta = []
	self.tNext = []
	self.normed = []
	cumulative_t = 0.0
	t = 0.0
	max_t = 0.0
	axis = 0
	
	static run = function ()
	{
		// init for the current sweep vector and take first step
		initSweep()
		if (max_t == 0)
		{
			return 0
		}

		axis = stepForward()

		// loop along raycast vector
		while (t <= max_t)
		{
			// sweeps over leading face of AABB
			if (checkCollision(axis))
			{
				// calls the callback and decides whether to continue
				var done = handleCollision()
				if (done)
				{
					return cumulative_t
				}
			}
			axis = stepForward()
		}

		// reached the end of the vector unobstructed, finish and exit
		cumulative_t += max_t
		for (var i = 0; i < 2; i++)
		{
			base[i] += vec[i]
			maxx[i] += vec[i]
		}
		return cumulative_t
	}

	// low-level implementations of each step:
	static initSweep = function ()
	{

		// parametrization t along raycast
		t = 0.0
		
		max_t = vec[0] * vec[0] + vec[1] * vec[1]
		if max_t == 0
		{
			return
		}
		max_t = sqrt(max_t)
		for (var i = 0; i < 2; i++)
		{
			var dir = (vec[i] >= 0)
			step[i] = dir ? 1 : -1
			// trailing / trailing edge coords
			var lead = dir ? maxx[i] : base[i]
			tr[i] = dir ? base[i] : maxx[i]
			// int values of lead/trail edges
			ldi[i] = leadEdgeToInt(lead, step[i])
			tri[i] = trailEdgeToInt(tr[i], step[i])
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
	static checkCollision = function (i_axis)
	{
		var stepx = step[0]
		var x0 = (i_axis == 0) ? ldi[0] : tri[0]
		var x1 = ldi[0] + stepx

		var stepy = step[1]
		var y0 = (i_axis == 1) ? ldi[1] : tri[1]
		var y1 = ldi[1] + stepy

		for (var xx = x0; xx != x1; xx += stepx)
		{
			for (var yy = y0; yy != y1; yy += stepy)
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
	static handleCollision = function ()
	{
		// set up for callback
		cumulative_t += t
		var dir = step[axis]

		// vector moved so far, and left to move
		var done = t / max_t
		var left = left_arr
		for (var i = 0; i < 2; i++)
		{
			var dv = vec[i] * done
			base[i] += dv
			maxx[i] += dv
			left[i] = vec[i] - dv
		}

		// set leading edge of stepped axis exactly to voxel boundary
		// else we'll sometimes rounding error beyond it
		if (dir > 0)
		{
			max[axis] = floor(maxx[axis] + 0.5)
		}
		else
		{
			base[axis] = floor(base[axis] + 0.5)
		}

		// call back to let client update the "left to go" vector
		var res = callback(cumulative_t, axis, dir, left)

		// bail out out on truthy response
		if (res)
		{
			return true
		}

		// init for new sweep along vec
		for (var i = 0; i < 2; i++)
		{
			vec[i] = left[i]
		}
		initSweep()
		if max_t == 0
		{
			return true // no vector left
		}
		return false
    }


	// advance to next voxel boundary, and return which axis was stepped
	static stepForward = function ()
	{
		var axis = tNext[0] < tNext[1] ? 0 : 1
		
		//var axis = (tNext[0] < tNext[1]) ?
		//	((tNext[0] < tNext[2]) ? 0 : 2) :
		//	((tNext[1] < tNext[2]) ? 1 : 2)
		var dt = tNext[axis] - t
		t = tNext[axis]
		ldi[axis] += step[axis]
		tNext[axis] += tDelta[axis]
		for (var i = 0; i < 2; i++)
		{
			tr[i] += dt * normed[i]
			tri[i] = trailEdgeToInt(tr[i], step[i])
		}

		return axis
	}

	static leadEdgeToInt = function(coord, step)
	{
		return floor(coord - step * EPS)
	}
	static trailEdgeToInt = function (coord, step)
	{
		return floor(coord + step * EPS)
	}
end
