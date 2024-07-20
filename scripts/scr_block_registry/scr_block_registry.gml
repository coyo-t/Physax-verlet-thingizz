
global.block_soundtypes = {
	none:  new BlockSoundType( , 0.8),
	dirt:  new BlockSoundType( , 0.6, "pl_step_dirt"),
	tile:  new BlockSoundType( , 0.8, "pl_step_tile"),
	grate: new BlockSoundType( , 0.5, "pl_step_grate"),
}

global.blocks_all/*Array<Block>*/ = []
global.blocks_nametable/*Dict<String, Block>*/ = {}

/*generic(T=Block)*/
function blocks_register (_name/*String*/, _block/*T*/)/*T*/
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


#region registering

with blocks_register("air", new AirBlock())
{
	global.air = self
}

with blocks_register("out_of_bounds", new OutOfBoundsBlock())
{
	global.out_of_bounds = self
}

with blocks_register("stone", new Block())
{
	global.stone = self
	colour = c_grey
	sound_type = global.block_soundtypes.tile
}

with blocks_register("dirt", new Block())
{
	global.dirt = self
	colour = c_orange
	sound_type = global.block_soundtypes.dirt
}

with blocks_register("slab", new SlabBlock())
{
	global.slab = self
	colour = c_grey
}

with blocks_register("quarter_slab", new SlabBlock(0.25))
{
	global.quarter_slab = self
	colour = c_grey
}

with blocks_register("upper_slab", new SlabBlock(1, 0.5))
{
	global.upper_slab = self
	colour = c_ltgrey
}

with blocks_register("precarious", new FenceBlock())
{
	global.precarious = self
	colour = merge_color(c_orange, c_black, 0.4)
}

with blocks_register("left_stairs", new StairBlock(-1))
{
	global.left_stair = self
	colour = c_aqua
}

with blocks_register("right_stairs", new StairBlock(+1))
{
	global.right_stair = self
	colour = c_teal
}

with blocks_register("top_platform", new EndlessBlock(+1))
{
	global.endless_down = self
	colour = c_red
	sound_type = global.block_soundtypes.grate
}

with blocks_register("bottom_platform", new EndlessBlock(-1))
{
	global.endless_up = self
	colour = c_maroon
	sound_type = global.block_soundtypes.grate
}

with blocks_register("left_ladder", new LadderBlock("left"))
{
	global.left_ladder = self
	colour = c_orange
}

with blocks_register("right_ladder", new LadderBlock("right"))
{
	global.right_ladder = self
	colour = c_orange
}

with blocks_register("lego_studs", new ColliderCollectionBlock())
{
	global.lego_studs = self
	colour = c_lime
	
	__add_colliders(
		rect_get_temp(2/16, 0, 4/16, 1/16),
		rect_get_temp((16-4)/16, 0, (16-2)/16, 1/16)
	)
}

with blocks_register("shit_ramp", new ColliderCollectionBlock())
{
	global.tiny_stairs = self
	colour = c_lime

	for (var i = 1; i <= 16; i++)
	{
		__add_collider(rect_get_temp(0, 1-(i/16), i/16, 1-(i-1)/16))
	}
}

with blocks_register("ice", new IceBlock())
{
	global.ice = self
	colour = #7bc6fc
	sound_type = global.block_soundtypes.tile
}

with blocks_register("tilled_dirt", new Block())
{
	global.tilled_dirt = self
	colour = #824d1c
	sound_type = global.block_soundtypes.dirt
	rect_set_y1(shape, 15/16)
}


#endregion



