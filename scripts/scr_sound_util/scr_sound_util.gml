

function get_sound_set (tag_name/*:string*/) /*-> array<sound>*/
{
	return tag_get_asset_ids("pl_step_generic", asset_sound)
}

