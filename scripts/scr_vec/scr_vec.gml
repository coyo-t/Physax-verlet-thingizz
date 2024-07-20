

enum Vec {
	x,
	y,
	sizeof
}

function vec_create (_x/*:number*/=0, _y/*:number*/=0) /*-> Vec*/
{
	return [_x, _y]
}

function vec_get_x (_self/*:Vec*/) /*-> number*/
{
	return _self[Vec.x]
}

function vec_get_y (_self/*:Vec*/) /*-> number*/
{
	return _self[Vec.y]
}

function vec_set_x (_self/*:Vec*/, v/*:number*/) /*-> Vec*/
{
	_self[@Vec.x] = v
	return _self
}

function vec_set_y (_self/*:Vec*/, v/*:number*/) /*-> Vec*/
{
	_self[@Vec.y] = v
	return _self
}

function vec_set_xy (_self/*:Vec*/, _x/*:number*/=0, _y/*:number*/=0) /*-> Vec*/
{
	_self[@Vec.x] = _x
	_self[@Vec.y] = _y
	return _self
}

function vec_set_from (_self/*:Vec*/, _other/*:Vec*/) /*-> Vec*/
{
	return vec_set_xy(_self, _other[Vec.x], _other[Vec.y])
}

function vec_xy (_self/*:Vec*/) /*-> Vec*/
{
	return vec_create(_self[Vec.x], _self[Vec.y])
}

function vec_yx (_self/*:Vec*/) /*-> Vec*/
{
	return vec_create(_self[Vec.y], _self[Vec.x])
}

function vec_dot (_self/*:Vec*/, _other/*:Vec*/) /*-> number*/
{
	return dot_product(_self[Vec.x], _self[Vec.y], _other[Vec.x], _other[Vec.y])
}

function vec_sqr_length (_self/*:Vec*/) /*-> number*/
{
	var xx = _self[Vec.x]
	var yy = _self[Vec.y]
	return dot_product(xx,yy,xx,yy)
}

function vec_add_xy (_self/*:Vec*/, _x/*:number*/, _y/*:number*/) /*-> Vec*/
{
	_self[@Vec.x] += _x
	_self[@Vec.y] += _y
	return _self
}
function vec_add_vec (_self/*:Vec*/, _other/*:Vec*/) /*-> Vec*/
{
	return vec_add_xy(_self, _other[Vec.x], _other[Vec.y])
}

function vec_copy (_self/*:Vec*/) /*-> Vec*/
{
	return vec_create(_self[Vec.x], _self[Vec.y])
}



