
global.block_soundtypes = {
	none:  new BlockSoundType(, 0.8),
	dirt:  new BlockSoundType(, 0.6, "pl_step_dirt"),
	tile:  new BlockSoundType(, 0.8, "pl_step_tile"),
	grate: new BlockSoundType(, 0.5, "pl_step_grate"),
}

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
with global.stone
{
	colour = c_grey
	sound_type = global.block_soundtypes.tile
}

global.dirt = blocks_register("dirt", new Block()) ///@is {Block}
with global.dirt
{
	colour = c_orange
	sound_type = global.block_soundtypes.dirt
}

global.slab = blocks_register("slab", new SlabBlock()) ///@is {SlabBlock}
global.slab.colour = c_grey

global.quarter_slab = blocks_register("slab", new SlabBlock(0.25)) ///@is {SlabBlock}
global.quarter_slab.colour = c_grey

global.upper_slab = blocks_register("upper_slab", new SlabBlock(1, 0.5))
global.quarter_slab.colour = c_ltgrey

global.precarious = blocks_register("precarious", new FenceBlock()) ///@is {FenceBlock}
global.precarious.colour = merge_color(c_orange, c_black, 0.4)

global.left_stair = blocks_register("left_stairs", new StairBlock(-1)) ///@is {StairBlock}
global.left_stair.colour = c_aqua

global.right_stair = blocks_register("right_stairs", new StairBlock(+1)) ///@is {StairBlock}
global.right_stair.colour = c_teal

global.endless_down = blocks_register("top_platform", new EndlessBlock(+1))
with global.endless_down
{
	colour = c_red
	sound_type = global.block_soundtypes.grate
}

global.endless_up = blocks_register("bottom_platform", new EndlessBlock(-1))
with global.endless_up
{
	colour = c_maroon
	sound_type = global.block_soundtypes.grate
}

global.left_ladder = blocks_register("left_ladder", new LadderBlock("left"))
global.left_ladder.colour = c_orange

global.right_ladder = blocks_register("right_ladder", new LadderBlock("right"))
global.right_ladder.colour = c_orange









