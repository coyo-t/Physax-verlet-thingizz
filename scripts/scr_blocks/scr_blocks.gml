
PREDICATE_TRUE = function () { return true }
PREDICATE_FALSE = function () { return false }

function Block () constructor begin
	id = 0
	name = ""
	colour = c_white
	
	shape = new Rect(0, 0, 1, 1)
	
	///@func drawable
	///@returns {Bool}
	static drawable = global.PREDICATE_TRUE

	///@func show_in_palette
	///@returns {Bool}
	static show_in_palette = global.PREDICATE_TRUE
	
	///@func collideable
	///@returns {Bool}
	static collideable = global.PREDICATE_TRUE
end

function AirBlock () : Block() constructor begin
	
	static drawable = global.PREDICATE_FALSE
	
	static show_in_palette = global.PREDICATE_FALSE

	static collideable = global.PREDICATE_FALSE
end

function OutOfBoundsBlock () : Block() constructor begin
	
	static show_in_palette = global.PREDICATE_FALSE
	
end

function SlabBlock (_height=0.5) : Block() constructor begin
	shape.set_corners(0, 0, 1, _height)
end

/// @type {Array<Struct.Block>}
global.blocks_all = []
global.blocks_nametable = {}


///@arg {String} _name
///@arg {Struct.Block} _block
function block_register (_name, _block)
{
	static blocks = global.blocks_all
	static nt = global.blocks_nametable
	
	_block.id = array_length(blocks)
	array_push(blocks, _block)
	_block.name = _name
	nt[$ _name] = _block
	
	return _block
}

///@arg {Real, String} _id_or_name
///@returns {Struct.Block}
function block_get (_id_or_name)
{
	if is_string(_id_or_name)
	{
		if variable_struct_exists(global.blocks_nametable, _id_or_name)
		{
			return global.blocks_nametable[$ _id_or_name]
		}
	}
	else if is_real(_id_or_name)
	{
		return global.blocks_all[_id_or_name]
	}
	return air
}


air = block_register("air", new AirBlock())

out_of_bounds = block_register("out_of_bounds", new OutOfBoundsBlock())

stone = block_register("stone", new Block())
stone.colour = c_grey

dirt = block_register("dirt", new Block())
dirt.colour = c_orange

slab = block_register("slab", new SlabBlock())
slab.colour = c_grey

quarter_slab = block_register("slab", new SlabBlock(0.25))
quarter_slab.colour = c_grey
