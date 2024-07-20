


global.blocks_all = [] ///@is {array<Block>}
global.blocks_nametable = {}

//!#mfunc block_by_id {"args":["__id__"],"order":[0]}
#macro block_by_id_mf0  (global.blocks_all[(
#macro block_by_id_mf1 )])
//!#mfunc block_by_name {"args":["__name__"],"order":[0]}
#macro block_by_name_mf0  (global.blocks_nametable[$ (
#macro block_by_name_mf1 )])

function blocks_register (_name/*:string*/, _block/*:Block*/) /*-> Block*/
{
	_block.runtime_id = array_length(global.blocks_all)
	array_push(global.blocks_all, _block)
	_block.name = _name
	global.blocks_nametable[$ _name] = _block
	
	return _block
}

function blocks_get_by_id (_id)
{
	return global.blocks_all[_id]
}

global.air = blocks_register("air", new AirBlock()) ///@is {AirBlock}

global.out_of_bounds = blocks_register("out_of_bounds", new OutOfBoundsBlock()) ///@is {OutOfBoundsBlock}

global.stone = blocks_register("stone", new Block()) ///@is {Block}
global.stone.colour = c_grey

global.dirt = blocks_register("dirt", new Block()) ///@is {Block}
global.dirt.colour = c_orange

global.slab = blocks_register("slab", new SlabBlock()) ///@is {SlabBlock}
global.slab.colour = c_grey

global.quarter_slab = blocks_register("slab", new SlabBlock(0.25)) ///@is {SlabBlock}
global.quarter_slab.colour = c_grey

global.precarious = blocks_register("precarious", new FenceBlock()) ///@is {FenceBlock}
global.precarious.colour = merge_color(c_orange, c_black, 0.4)

global.left_stair = blocks_register("left_stairs", new StairBlock(-1)) ///@is {StairBlock}
global.left_stair.colour = c_aqua

global.right_stair = blocks_register("right_stairs", new StairBlock(+1)) ///@is {StairBlock}
global.right_stair.colour = c_teal
