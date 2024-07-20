
enum Rect
{
	x0,
	y0,
	x1,
	y1,
	sizeof
}

function rect_create (_x0/*:number*/, _y0/*:number*/, _x1/*:number*/, _y1/*:number*/) /*-> Rect*/
{
	return rect_set_corners(array_create(Rect.sizeof), _x0, _y0, _x1, _y1)
}

function rect_set_corners (_self/*:Rect*/, _x0/*:number*/, _y0/*:number*/, _x1/*:number*/, _y1/*:number*/) /*-> Rect*/
{
	_self[@Rect.x0] = _x0
	_self[@Rect.y0] = _y0
	_self[@Rect.x1] = _x1
	_self[@Rect.y1] = _y1
	return _self
}

function rect_set_from (_self/*:Rect*/, _other/*:Rect*/) /*-> Rect*/
{
	return rect_set_corners(_self, _other[Rect.x0], _other[Rect.y0], _other[Rect.x1], _other[Rect.y1])
}

function rect_get_wide (_self/*:Rect*/) /*-> number*/
{
	return _self[Rect.x1] - _self[Rect.x0]
}

function rect_get_tall (_self/*:Rect*/) /*-> number*/
{
	return _self[Rect.y1] - _self[Rect.y0]
}

function rect_overlapping (_self/*:Rect*/, _other/*:Rect*/) /*-> bool*/
{
	return _other[Rect.x1]>_self[Rect.x0]&&_other[Rect.x0]<_self[Rect.x1]&&_other[Rect.y1]>_self[Rect.y0]&&_other[Rect.y0]<_self[Rect.y1]
}

function rect_copy (_self/*:Rect*/) /*-> Rect*/
{
	return rect_create(_self[Rect.x0], _self[Rect.y0], _self[Rect.x1], _self[Rect.y1])
}

function rect_expand (_self/*:Rect*/, xofs/*:number*/, yofs/*:number*/) /*-> Rect*/
{
	return rect_create(
		_self[Rect.x0] + (xofs < 0 ? xofs : 0),
		_self[Rect.y0] + (yofs < 0 ? yofs : 0),
		_self[Rect.x1] + (xofs > 0 ? xofs : 0),
		_self[Rect.y1] + (yofs > 0 ? yofs : 0)
	)
}

function rect_move (_self/*:Rect*/, _x/*:number*/, _y/*:number*/) /*-> Rect*/
{
	_self[@Rect.x0] += _x
	_self[@Rect.y0] += _y
	_self[@Rect.x1] += _x
	_self[@Rect.y1] += _y
	return _self
}

function rect_moved (_self/*:Rect*/, _x/*:number*/, _y/*:number*/) /*-> Rect*/
{
	return rect_create(
		_self[Rect.x0]+_x,
		_self[Rect.y0]+_y,
		_self[Rect.x1]+_x,
		_self[Rect.y1]+_y
	)
}


function rect_clip_x_collide (_self/*:Rect*/, c/*:Rect*/, xa/*:number*/) /*-> number*/
{
	if c[Rect.y1] <= _self[Rect.y0] or c[Rect.y0] >= _self[Rect.y1]
	{
		return xa
	}
	if xa > 0 and c[Rect.x1] <= _self[Rect.x0]
	{
		xa = min(xa, _self[Rect.x0] - c[Rect.x1])
	}
	if xa < 0 and c[Rect.x0] >= _self[Rect.x1]
	{
		xa = max(xa, _self[Rect.x1] - c[Rect.x0])
	}
	return xa
}

function rect_clip_y_collide (_self/*:Rect*/, c/*:Rect*/, ya/*:number*/) /*-> number*/
{
	if c[Rect.x1] <= _self[Rect.x0] or c[Rect.x0] >= _self[Rect.x1]
	{
		return ya
	}
	if ya > 0 and c[Rect.y1] <= _self[Rect.y0]
	{
		ya = min(ya, _self[Rect.y0] - c[Rect.y1])
	}
	if ya < 0 and c[Rect.y0] >= _self[Rect.y1]
	{
		ya = max(ya, _self[Rect.y1] - c[Rect.y0])
	}
	return ya
}





// function Rect (_x0:number, _y0:number, _x1:number, _y1:number) constructor begin
// 	self.x0 = _x0
// 	self.y0 = _y0
// 	self.x1 = _x1
// 	self.y1 = _y1
	
// 	///@func set_corners
// 	///@arg {Real} x0
// 	///@arg {Real} y0
// 	///@arg {Real} x1
// 	///@arg {Real} y1
// 	///@returns {Struct.Rect}
// 	static set_corners = function (x0:number, y0:number, x1:number, y1:number) -> self
// 	{
// 		self.x0 = x0
// 		self.y0 = y0
// 		self.x1 = x1
// 		self.y1 = y1
// 		return self
// 	}
	
// 	///@func set_from
// 	///@arg {Struct.Rect} _other
// 	///@returns {Struct.Rect} self
// 	static set_from = function (_other)
// 	{
// 		return set_corners(_other.x0, _other.y0, _other.x1, _other.y1)
// 	}
	
// 	///@func get_wide
// 	///@returns {Real}
// 	static get_wide = function () { return x1 - x0 }
	
// 	///@func get_tall
// 	///@returns {Real}
// 	static get_tall = function () { return y1 - y0 }
	
// 	///@func overlapping
// 	///@arg {Struct.Rect} _other
// 	///@returns {Bool}
// 	static overlapping = function (_other)
// 	{
// 		return (_other.x1>x0&&_other.x0<x1)&&(_other.y1>y0&&_other.y0<y1)
// 	}
	
// 	static copy = function ()
// 	{
// 		return new Rect(x0, y0, x1, y1)
// 	}
	
// 	static expand = function (xofs, yofs)
// 	{
// 		return new Rect(
// 			xofs < 0 ? x0 + xofs : x0,
// 			yofs < 0 ? y0 + yofs : y0,
// 			xofs > 0 ? x1 + xofs : x1,
// 			yofs > 0 ? y1 + yofs : y1
// 		)
// 	}
	
// 	///@func move
// 	///@arg {Real} x
// 	///@arg {Real} y
// 	///@returns {Struct.Rect} self
// 	static move = function (x, y)
// 	{
// 		x0 += x
// 		y0 += y
// 		x1 += x
// 		y1 += y
// 		return self
// 	}
	
// 	///@func moved
// 	///@arg {Real} x
// 	///@arg {Real} y
// 	///@returns {Struct.Rect} new
// 	static moved = function (x, y)
// 	{
// 		return copy().move(x, y)
// 	}
	
// 	///@func clip_x_collide 
// 	///@arg {Struct.Rect} c
// 	///@arg {Real} xa
// 	///@returns {Real}
// 	static clip_x_collide = function (c, xa)
// 	{
// 		if (c.y1 <= y0 || c.y0 >= y1)
// 		{
// 			return xa
// 		}
// 		if xa > 0 and c.x1 <= x0
// 		{
// 			var bmx = x0 - c.x1// - epsilon;
// 			if bmx < xa
// 			{
// 				xa = bmx
// 			}
// 		}
// 		if xa < 0 and c.x0 >= x1
// 		{
// 			var bmx = x1 - c.x0// + epsilon;
// 			if bmx > xa
// 			{
// 				xa = bmx
// 			}
// 		}
// 		return xa
// 	}
	
// 	///@func clip_y_collide 
// 	///@arg {Struct.Rect} c
// 	///@arg {Real} ya
// 	///@returns {Real}
// 	static clip_y_collide = function (c, ya)
// 	{
// 		if (c.x1 <= x0 || c.x0 >= x1)
// 		{
// 			return ya
// 		}
// 		if ya > 0 and c.y1 <= y0
// 		{
// 			var bmy = y0 - c.y1// - epsilon;
// 			if bmy < ya
// 			{
// 				ya = bmy
// 			}
// 		}
// 		if ya < 0 and c.y0 >= y1
// 		{
// 			var bmy = y1 - c.y0// + epsilon;
// 			if bmy > ya
// 			{
// 				ya = bmy
// 			}
// 		}
// 		return ya
// 	}
// end
