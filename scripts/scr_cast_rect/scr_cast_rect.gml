
function RayRectContext () constructor begin
	
	origin_x = 0
	origin_y = 0
	
	direction_x = 0
	direction_y = 0
	inv_direction_x = 1
	inv_direction_y = 1
	inv_x_infinite = false
	inv_y_infinite = false
	
	inflate_x = 0
	inflate_y = 0
	
	sign_x = 0
	sign_y = 0
	
	near_time = 1.0
	far_time = 1.0
	hit_time = 1.0
	did_hit = false
	
	hit_normal_x = 0
	hit_normal_y = 0
	
	static setup_ray = function (_x, _y, _xd, _yd)
	{
		origin_x = _x
		origin_y = _y
		
		direction_x = _xd
		direction_y = _yd
		
		inv_x_infinite = _xd == 0
		inv_y_infinite = _yd == 0
		inv_direction_x = 1 / _xd
		inv_direction_y = 1 / _yd
		
		sign_x = _xd < 0 ? -1 : +1// sign(_xd)
		sign_y = _yd < 0 ? -1 : +1//sign(_yd)
		//sign_x = sign(_xd)
		//sign_y = sign(_yd)
	}
	
	static setup_box_ray = function (_x0, _y0, _x1, _y1, _xdirection, _ydirection)
	{
		var xx = (_x0+_x1) * 0.5
		var yy = (_y0+_y1) * 0.5
		setup_ray(xx, yy, _xdirection, _ydirection)
		inflate_x = xx-_x0
		inflate_y = yy-_y0
	}
	
	static setup_endpoints = function (_xstart, _ystart, _xend, _yend)
	{
		setup_ray(_xstart, _ystart, _xend-_xstart, _yend-_ystart)
	}
	
	static test_rect = function (_rect)
	{
		return test(
			rect_get_x0(_rect),
			rect_get_y0(_rect),
			rect_get_x1(_rect),
			rect_get_y1(_rect)
		)
	}
	
	static test = function (_x0, _y0, _x1, _y1)/*Number*/
	{
		did_hit = false
		hit_time = 1
		hit_normal_x = 0
		hit_normal_y = 0

		if _x0 <= origin_x and origin_x <= _x1 and _y0 <= origin_y and origin_y <= _y1
		{
			return false
		}
		
		near_time = +infinity
		far_time  = -infinity
		
		var nx = 0
		var ny = 0
		
		// it is perhaps superfluous to do explicit horizontal/vertical checks
		// however, i really dont feel like figuring out a good way to avoid
		// this algorithm breaking down when one direction compoenent is 0 for now
		// :/
		//if direction_y == 0
		//{
		//	if _y0 <= origin_y and origin_y <= _y1
		//	{
		//		var n = direction_x < 0
		//		nx = n * 2 - 1
		//		var xx0 = _x0 - origin_x
		//		var xx1 = _x1 - origin_x
		//		near_time = ((n ? xx1 : xx0) - inflate_x*sign_x) * inv_direction_x
		//		far_time  = ((n ? xx0 : xx1) + inflate_x*sign_x) * inv_direction_x
		//	}
		//}
		//else if direction_x == 0
		//{
		//	if _x0 <= origin_x and origin_x <= _x1
		//	{
		//		var n = direction_y < 0
		//		ny = n * 2 - 1
		//		var yy0 = _y0 - origin_y
		//		var yy1 = _y1 - origin_y
		//		near_time = ((n ? yy1 : yy0) - inflate_y*sign_y) * inv_direction_y
		//		far_time  = ((n ? yy0 : yy1) + inflate_y*sign_y) * inv_direction_y
		//	}
		//}
		//else
		{
			var hw = (_x1-_x0) * 0.5
			var hh = (_y1-_y0) * 0.5
			var cx = _x0 + hw
			var cy = _y0 + hh
		
			var vfx = (hw + inflate_x) * sign_x
			var vfy = (hh + inflate_y) * sign_y
		
			var near_time_x = (cx - vfx - origin_x) * inv_direction_x
			var near_time_y = (cy - vfy - origin_y) * inv_direction_y
			var far_time_x  = (cx + vfx - origin_x) * inv_direction_x
			var far_time_y  = (cy + vfy - origin_y) * inv_direction_y
		
			if near_time_x > far_time_y or near_time_y > far_time_x
			{
				return false
			}
		
			near_time = max(near_time_x, near_time_y)
			far_time  = min(far_time_x, far_time_y)
			
			if near_time_x > near_time_y
			{
				nx = -sign_x
			}
			else
			{
				ny = -sign_y
			}
		}
		
		if near_time >= 1 or far_time <= 0
		{
			return false
		}
		
		did_hit = true
		hit_time = clamp(near_time, 0, 1)
		
		hit_normal_x = nx
		hit_normal_y = ny
		return true
	}
	
end


function RectCastRectContext () constructor begin
	
	x0 = 0
	y0 = 0
	x1 = 0
	y1 = 0
	
	half_wide = 0
	half_tall = 0
	
	xcentre = 0
	ycentre = 0
	
	xdirection = 0
	ydirection = 0
	
	inv_direction_x = 1
	inv_direction_y = 1
	
	
	static setup = function (_rect/*Rect*/, _direction/*Vec*/)
	{
		set_rect_corners(
			rect_get_x0(_rect),
			rect_get_y0(_rect),
			rect_get_x1(_rect),
			rect_get_y1(_rect)
		)
		set_direction_xy(vec_get_x(_direction), vec_get_y(_direction))
	}
	
	static set_direction_xy = function (_x, _y)
	{
		xdirection = _x
		ydirection = _y
		inv_direction_x = _x == 0 ? infinity : 1 / _x
		inv_direction_y = _y == 0 ? infinity : 1 / _y
	}
	
	static set_rect_corners = function (_x0, _y0, _x1, _y1)
	{
		x0 = _x0
		y0 = _y0
		x1 = _x1
		y1 = _y1
	
		half_wide = (_x1-_x0) * 0.5
		half_tall = (_y1-_y0) * 0.5
	
		xcentre = _x0 + half_wide
		ycentre = _y0 + half_tall
	}
	
	
end

function BlockTraceContext () constructor begin
	
	
	originX = 0.0
	originY = 0.0

	dirX = 0.0
	dirY = 1.0

	invDirX = 1.0;
	invDirY = 1.0;
	invPosX = true
	invPosY = true

	//face = Direction.UP

	static setup_ray = function (_origin/*Vec*/, _direction/*Vec*/)
	{
		dirX = _direction[0]
		dirY = _direction[1]
		originX = _origin[0]
		originY = _origin[1]

		invDirX = dirX == 0 ? infinity : 1 / dirX
		invDirY = dirY == 0 ? infinity : 1 / dirY
		invPosX = invDirX >= 0
		invPosY = invDirY >= 0
	}

	static setup_ray_endpoints = function (_start/*Vec*/, _end/*Vec*/)
	{
		setup_ray(_start, vec_get_temp(_end[0]-_start[0], _end[1]-_start[1]))
	}

	static get_hit_point = function (time/*Value*/, dst/*Vec*/)/*Vec*/
	{
		return vec_set_xy(dst, dirX*time+originX, dirY*time+originY)
	}

	static origin_in = function (
		_x0/*Value*/, _y0/*Value*/,
		_x1/*Value*/, _y1/*Value*/
	)/*Boolean*/
	{
		return (
			_x0 <= originX and originX <= _x1 and
			_y0 <= originY and originY <= _y1
		)
	}

	static test_simple = function(
		_x0/*Value*/, _y0/*Value*/,
		_x1/*Value*/, _y1/*Value*/
	)/*Value*/
	{
		if origin_in(_x0,_y0,_x1,_y1)
		{
			return infinity
		}

		var tNear/*Value*/
		var tFar /*Value*/
		var tymin/*Value*/
		var tymax/*Value*/

		if (invPosX)
		{
			tNear = (_x0 - originX) * invDirX
			tFar  = (_x1 - originX) * invDirX
		}
		else
		{
			tNear = (_x1 - originX) * invDirX
			tFar  = (_x0 - originX) * invDirX
		}
		if (invPosY)
		{
			tymin = (_y0 - originY) * invDirY
			tymax = (_y1 - originY) * invDirY
		}
		else
		{
			tymin = (_y1 - originY) * invDirY
			tymax = (_y0 - originY) * invDirY
		}

		if tNear > tymax or tymin > tFar
		{
			return infinity
		}
		
		//face = if (invPosX) Direction.WEST else Direction.EAST
		
		if tymin > tNear or tNear >= infinity
		{
			//face = if (invPosY) Direction.SOUTH else Direction.NORTH
			tNear = tymin
		}
		if tymax < tFar or tFar >= infinity
		{
			tFar = tymax
		}

		if tNear <= 1 and tNear < tFar and tFar >= 0
		{
			return tNear
		}
		return infinity
	}
end

