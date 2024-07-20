
enum BlockRenderLayerIndex
{
	DEFAULT,
	TRANSLUSCENT,
	MANY_HULLS,
	SIZEOF
}

function Block () constructor {
	
	runtime_id/*Int*/ = 0
	
	name/*String*/ = ""
	
	colour/*Colour*/ = c_white
	
	shape/*Rect*/ = rect_create(0, 0, 1, 1)
	
	sound_type/*BlockSoundType*/ = global.block_soundtypes.none
	
	ground_slipperiness/*Value*/ = 0.6
	
	render_layer_index/*BlockRenderLayerIndex*/ = 0
	
	static is_solid = function ()
	{
		return true
	}
	
	static drawable = function () /*-> bool*/
	{
		return true
	}

	static show_in_palette = function () /*-> bool*/
	{
		return true
	}
	
	static collideable = function () /*-> bool*/
	{
		return true
	}
	
	static get_colliders = function (_xofs/*:number*/, _yofs/*:number*/)/*->array<Rect>*/
	{
		return [ rect_move(rect_copy_temp(shape), _xofs, _yofs) ]
	}
	
	static get_render_shapes = function () /*-> array<Rect>*/
	{
		return [ rect_copy_temp(shape) ]
	}
	
	static is_climbable = function ()/*->Boolean*/
	{
		return false
	}
	
	static __set_friction = function (_value/*:Number*/)
	{
		ground_slipperiness = 1 - _value
	}
}

function AirBlock () : Block() constructor begin
	
	ground_slipperiness = 0.6//*0.91
	
	static is_solid = function ()
	{
		return false
	}
	
	static drawable = function ()/*Boolean*/
	{
		return false
	}
	
	static show_in_palette = function ()/*Boolean*/
	{
		return false
	}

	static collideable = function ()/*Boolean*/
	{
		return false
	}
end

function OutOfBoundsBlock () : Block() constructor begin
	
	static show_in_palette = function ()/*Boolean*/
	{
		return false
	}
	
end

function SlabBlock (_height=0.5, _base=0.0) : Block() constructor begin
	rect_set_corners(shape, 0, _base, 1, _height)
end

function FenceBlock () : Block() constructor begin
	
	var texels = 1/16
	rect_set_corners(shape, 0.5-texels*2, 0, 0.5+texels*2, 1)
	
	// shape.set_corners(0.5-texels*2, 0, 0.5+texels*2, 1)
	
	collider_shape = rect_add_corners(rect_copy(shape), 0, 0, 0, 0.5)
	
	static get_colliders = function (_xofs, _yofs)
	{
		return [ rect_move(rect_copy_temp(collider_shape), _xofs, _yofs) ]
	}
end

function StairBlock (_facing) : Block() constructor begin
	
	rect_set_corners(shape, 0, 0, 1, 0.5)
	shape_top = rect_create(0,0,0,0) ///@is {Rect}
	
	if _facing < 0
	{
		rect_set_corners(shape_top, 0.5, 0.5, 1, 1)
	}
	else if _facing > 0
	{
		rect_set_corners(shape_top, 0, 0.5, 0.5, 1)
	}
	
	static get_colliders = function (_xofs, _yofs)
	{
		return [
			rect_move(rect_copy_temp(shape),     _xofs, _yofs),
			rect_move(rect_copy_temp(shape_top), _xofs, _yofs)
		]
	}
	
	static get_render_shapes = function ()
	{
		return [rect_copy_temp(shape), rect_copy_temp(shape_top)]
	}
end

function EndlessBlock (_direction) : Block() constructor begin
	
	if _direction > 0
	{
		rect_set_corners(shape, 0, -infinity, 1, 1)
	}
	else if _direction < 0
	{
		rect_set_corners(shape, 0, 0, 1, +infinity)
	}
	
	display = rect_create(0,0,1,1)
	
	static is_solid = function ()
	{
		return false
	}
	
	static get_render_shapes = function () /*-> array<Rect>*/
	{
		return [ rect_copy_temp(display) ]
	}
end

function LadderBlock (_side) : Block() constructor begin
	switch (_side)
	{
		case "left":
			rect_set_x1(shape, 0.125)
			break
		case "right":
			rect_set_x0(shape, 1-0.125)
			break
	}
	
	static is_climbable = function ()/*->Boolean*/
	{
		return true
	}
end

function ColliderCollectionBlock () : Block() constructor begin
	shapes = []
	render_layer_index = BlockRenderLayerIndex.MANY_HULLS
	
	static __add_collider = function (c)
	{
		array_push(shapes, rect_copy(c))
	}
	
	static __add_colliders = function (/*...:Rect*/)
	{
		for (var i = argument_count; i > 0;)
		{
			__add_collider(rect_copy(argument[--i]))
		}
	}
	
	
	static get_render_shapes = function () /*-> array<Rect>*/
	{
		var sz = array_length(shapes)
		var outs = array_create(sz)
		
		for (var i = sz; (--i) >= 0;)
		{
			outs[i] = rect_copy_temp(shapes[i])
		}
		return outs
	}
	
	static get_colliders = function (_xofs, _yofs)
	{
		var sz = array_length(shapes)
		var outs = array_create(sz)
		
		for (var i = sz; (--i) >= 0;)
		{
			outs[i] = rect_move(rect_copy_temp(shapes[i]), _xofs, _yofs)
		}
		return outs
	}
end


function IceBlock () : Block() constructor begin
	render_layer_index = BlockRenderLayerIndex.TRANSLUSCENT
	__set_friction(0.02)
	
end

