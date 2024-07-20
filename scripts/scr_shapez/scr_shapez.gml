function Rect (_x0, _y0, _x1, _y1) constructor begin
	x0 = _x0
	y0 = _y0
	x1 = _x1
	y1 = _y1
	
	///@func set_corners
	///@arg {Real} x0
	///@arg {Real} y0
	///@arg {Real} x1
	///@arg {Real} y1
	///@returns {Struct.Rect}
	static set_corners = function (x0, y0, x1, y1)
	{
		self.x0 = x0
		self.y0 = y0
		self.x1 = x1
		self.y1 = y1
		return self
	}
	
	///@func set_from
	///@arg {Struct.Rect} _other
	///@returns {Struct.Rect} self
	static set_from = function (_other)
	{
		return set_corners(_other.x0, _other.y0, _other.x1, _other.y1)
	}
	
	///@func get_wide
	///@returns {Real}
	static get_wide = function () { return x1 - x0 }
	
	///@func get_tall
	///@returns {Real}
	static get_tall = function () { return y1 - y0 }
	
	///@func overlapping
	///@arg {Struct.Rect} _other
	///@returns {Bool}
	static overlapping = function (_other)
	{
		return (_other.x1>x0&&_other.x0<x1)&&(_other.y1>y0&&_other.y0<y1)
	}
	
	static copy = function ()
	{
		return new Rect(x0, y0, x1, y1)
	}
	
	static expand = function (xofs, yofs)
	{
		return new Rect(
			xofs < 0 ? x0 + xofs : x0,
			yofs < 0 ? y0 + yofs : y0,
			xofs > 0 ? x1 + xofs : x1,
			yofs > 0 ? y1 + yofs : y1
		)
	}
	
	///@func move
	///@arg {Real} x
	///@arg {Real} y
	///@returns {Struct.Rect} self
	static move = function (x, y)
	{
		x0 += x
		y0 += y
		x1 += x
		y1 += y
		return self
	}
	
	///@func clip_x_collide 
	///@arg {Struct.Rect} c
	///@arg {Real} xa
	///@returns {Real}
	static clip_x_collide = function (c, xa)
	{
		if (c.y1 <= y0 || c.y0 >= y1)
		{
			return xa
		}
		if xa > 0 and c.x1 <= x0
		{
			var bmx = x0 - c.x1// - epsilon;
			if bmx < xa
			{
				xa = bmx
			}
		}
		if xa < 0 and c.x0 >= x1
		{
			var bmx = x1 - c.x0// + epsilon;
			if bmx > xa
			{
				xa = bmx
			}
		}
		return xa
	}
	
	///@func clip_y_collide 
	///@arg {Struct.Rect} c
	///@arg {Real} ya
	///@returns {Real}
	static clip_y_collide = function (c, ya)
	{
		if (c.x1 <= x0 || c.x0 >= x1)
		{
			return ya
		}
		if ya > 0 and c.y1 <= y0
		{
			var bmy = y0 - c.y1// - epsilon;
			if bmy < ya
			{
				ya = bmy
			}
		}
		if ya < 0 and c.y0 >= y1
		{
			var bmy = y1 - c.y0// + epsilon;
			if bmy > ya
			{
				ya = bmy
			}
		}
		return ya
	}
end
