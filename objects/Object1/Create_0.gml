
//!#import rect.* in Rect

#macro MODE_OBJECT  0
#macro MODE_EDIT    1
#macro MODE_COMMAND 2

__DEBUG_STRING = ""


step_sounds_generic = get_sound_set("pl_step_generic") ///@is{array<sound>}

tick = method(self, function() /*=>*/ {
	player_xprevious = player_x
	player_yprevious = player_y
	player_previous_bob = player_bob
	walk_dist_previous = walk_dist
	player_previous_tilt = player_tilt
	player_previous_fall_hurt_time = player_fall_hurt_time
	player_was_sneaking = player_sneaking
	rect_set_from(player_previous_box, player_box)
	tick_player()
})

timer/*:Timer*/ = new Timer(20)
timer.time_scale = 1

tempHitbox = rect_create(0,0,0,0) ///@is {Rect}

tempRect2 = rect_create(0,0,0,0) ///@is {Rect}

map = new Map(16, 8) ///@is {Map}

map.fill_region(0, 0, map.wide, 1, global.stone)

cam = new Camera() ///@is {Camera}

cam.x = map.wide / 2
cam.y = map.tall / 2

m_view = matrix_build_identity()
m_proj = matrix_build_identity()
m_inv_proj_view = matrix_build_identity()

world_mouse_x = 0
world_mouse_y = 0
cursor_x = 0
cursor_y = 0

viewcast_x = 0
viewcast_y = 0
viewcast_xdirection = 0
viewcast_ydirection = 0
viewcast_box_absolute = rect_create(-0.5, -0.5, 0.5, 0.5)
viewcast_box = rect_copy(viewcast_box_absolute)

__hit_x = 0
__hit_y = 0
var vc_getb = method(self, function (_x, _y) {
	var bloc = map.get_block(_x, _y)
	var collide = bloc.collideable()
	if collide
	{
		__hit_x = _x
		__hit_y = _y
	}
	return collide
})

var vc_onc = method(self, function (dist, axis, dir, remain)
{
	//show_debug_message($"dist: {dist}\naxis: {axis}\ndirection: {dir}\nremaining: {remain}")
	draw_rectangle_size(__hit_x, __hit_y, 1, 1, true)
	//draw_arrow(
	//	viewcast_x-1,
	//	viewcast_y-1,
	//	viewcast_x+remain[0]-1,
	//	viewcast_y*remain[1]-1,
	//	4/16
	//)
	remain[axis] = 0
	return true
})

viewcaster = new RectVoxelSweeper(
	viewcast_box,
	vec_create(),
	vc_getb,
	vc_onc
)

#region palette

palette = array_filter(global.blocks_all, function(bloc) /*=>*/ {return bloc.show_in_palette()}) ///@is{array<Block>}

current_paint = 0 ///@is{int}
previous_paint = -1
paint_changed = true
vertex_format_begin()
vertex_format_add_position_3d()
vertex_format_add_color()
palette_vb_format = vertex_format_end()

palette_vb = vertex_create_buffer()

function palette_vertex (_x, _y, _z, _c)
{
	vertex_position_3d(palette_vb, _x, _y, _z)
	vertex_color(palette_vb, _c, 1)
}

function palette_get_current ()/*-> Block*/
{
	return palette[current_paint]
}

begin
	var skew = [
		1, -0.5,   0, 0,
		1, +0.5,   0, 0,
		0,    1, 0.1, 0,
		0,    0,   0, 1
	]
	skew = [
		1,0,0,0,
		0,-1,0,0,
		-1,1,-1,0,
		0,0,0,1
	]
	var ofs = matrix_build_offset(-0.5, -0.5, -0.5)
	
	paint_matrix = matrix_multiply(ofs, skew)
	
	//paint_matrix = ofs
	matrix_stack_clear()

end

#endregion

#macro PLAYER_EYELINE_OFFSET (0.2)
#macro PLAYER_HEIGHT_STANDING (1.8)
#macro PLAYER_HEIGHT_SNEAKING (1.5-math_get_epsilon())

player_x/*:Number*/ = 0
player_y/*:Number*/ = 0

player_xprevious/*:Number*/ = 0
player_yprevious/*:Number*/ = 0

player_wide/*:Number*/ = 0.6
player_tall/*:Number*/ = PLAYER_HEIGHT_STANDING

player_box = rect_create(0,0,0,0) ///@is{Rect}
player_box_absolute = rect_create(0,0,0,0) ///@is{Rect}
player_previous_box = rect_create(0,0,0,0) ///@is{Rect}

player_eyeline = player_tall - PLAYER_EYELINE_OFFSET

player_bob = 0
player_previous_bob = 0
player_tilt = 0
player_previous_tilt = 0

player_jump_coyote_time_max = 2 * (1/20)
player_jump_coyote_time = player_jump_coyote_time_max

player_sneaking = false
player_was_sneaking = false

allow_jump_refire = 0

slide = true

wish_xdirection = 0
wish_ydirection = 0
wish_sneak = false

player_fall_hurt_time = 0
player_previous_fall_hurt_time = 0
player_superjump_charge = 0
on_ground = false
horizontal_collision = false
collision = false
height_offset = 0
y_slide_offset = 0
walk_dist = 0
walk_dist_previous = 0
speed_x = 0
speed_y = 0
fall_distance = 0
foot_size = 0.6
make_step_sounds = true
next_step = 0

///@self
function update_player_co (_x/*:number*/, _y/*:number*/, _include_pev=false)
{
	player_x = _x
	player_y = _y
	var hwide = player_wide * 0.5
	rect_set_corners(
		player_box_absolute,
		-hwide,
		0,
		+hwide,
		player_tall
	)
	sync_player_box_with_co()
	
	if _include_pev
	{
		player_xprevious = player_x
		player_yprevious = player_y
		rect_set_from(player_previous_box, player_box)
	}
}

///@self
function sync_player_box_with_co (_box=player_box)
{
	rect_set_from(_box, player_box_absolute)
	rect_move(_box, player_x, player_y-height_offset+y_slide_offset)
	player_eyeline = player_tall - PLAYER_EYELINE_OFFSET
}

///@self
function sync_player_co_with_box ()
{
	player_x = rect_get_centre_x(player_box)
	player_y = rect_get_y0(player_box) + height_offset - y_slide_offset
	player_eyeline = player_tall - PLAYER_EYELINE_OFFSET
}

///@self
///@returns whether or not the new height could be changed to
function player_try_change_height (_new_height/*:Number*/)/*->Boolean*/
{
	static temp = rect_create(0,0,0,0)
	static temp2 = rect_create(0,0,0,0)
	if _new_height == player_tall
	{
		return true
	}
	
	if _new_height < player_tall
	{
		player_tall = _new_height
		rect_set_y1(player_box_absolute, _new_height)
		sync_player_box_with_co()
		return true
	}
	
	
	rect_set_from(temp, player_box_absolute)
	rect_set_y1(player_box_absolute, _new_height)
	sync_player_box_with_co(temp2)
	if array_length(map.get_colliders(temp2)) > 0
	{
		rect_set_from(player_box_absolute, temp)
		return false
	}
	player_tall = _new_height
	rect_set_y1(player_box_absolute, _new_height)
	sync_player_box_with_co()
	return true
}

//update_player_co(map.wide * 0.5, map.tall)
update_player_co(map.wide * 0.5, 1.5, true)

rect_set_from(viewcast_box_absolute, player_box_absolute)

///@self
function move (xDirection/*:number*/, yDirection/*:number*/)
{
	y_slide_offset *= 0.4
	var x_begin = player_x
		
	var beginXD = xDirection;
	var beginYD = yDirection;
	//{
	//	var modv = trySneakClip(tempvec1.set(xDirection, yDirection, zDirection));
	//	xDirection = beginXD = modv.x;
	//	yDirection = beginYD = modv.y;
	//}
	
	rect_set_from(tempHitbox, player_box)
	var broadPhase/*:Array<Rect>*/ = map.get_colliders(rect_expand(player_box, xDirection, yDirection));
	
	begin
		// y axis
		var box/*:Rect*/
		for (var i = 0; i < array_length(broadPhase);)
		{
			box = broadPhase[i++]
			yDirection = rect_clip_y_collide(box, player_box, yDirection)
		}
		rect_move(player_box, 0, yDirection)
		
		var hitGround = on_ground or (yDirection <> beginYD && beginYD < 0)
			
		// x axis
		for (var i = 0; i < array_length(broadPhase);)
		{
			box = broadPhase[i++]
			xDirection = rect_clip_x_collide(box, player_box, xDirection)
		}
		rect_move(player_box, xDirection, 0)
		
	end
	var xCollided = beginXD <> xDirection

	// if we've horizontally collided, try to see if we can go further by moving by
	// our "foot size" (how tall of a step we can walk up)
	if foot_size > 0 and hitGround and (on_ground or y_slide_offset < 0.05) and (xCollided)
	{
		var bx = xDirection
		var by = yDirection
		xDirection = beginXD
		yDirection = foot_size
		
		rect_set_from(tempRect2, player_box)
		rect_set_from(player_box, tempHitbox)
		var cubz = map.get_colliders(rect_expand(player_box, xDirection, yDirection))
		var box
		
		for (var i = 0; i < array_length(cubz);)
		{
			box = cubz[i++]
			yDirection = rect_clip_y_collide(box, player_box, yDirection)
		}
		rect_move(player_box, 0, yDirection)
		
		for (var i = 0; i < array_length(cubz);)
		{
			box = cubz[i++]
			xDirection = rect_clip_x_collide(box, player_box, xDirection)
		}
		rect_move(player_box, xDirection, 0)
		
		{
			yDirection = -foot_size
			// This isnt very efficent, but it should solve the issue of very occasionally
			// missing a block when upstepping after hitting our head in the above steps
			// (and thusly bogusly setting our hitbox to be clipping into it when moving down here)
			
			var ttmp = map.get_colliders(rect_expand(player_box, bx, yDirection))
			
			for (var i = 0; i < array_length(ttmp);)
			{
				box = ttmp[i++]
				yDirection = rect_clip_y_collide(box, player_box, yDirection)
			}
			rect_move(player_box, 0, yDirection)
		}

		if abs(bx) >= abs(xDirection)
		{
			xDirection = bx;
			yDirection = by;
			rect_set_from(player_box, tempRect2)
		}
		else
		{
			// If we're sliding a small distance, dont add to yslideofs
			// this is to mask the jitters from walking across a corner like this:
			// Xx (x is the floor, X is 1 block above)
			// x
			var slideDelta = rect_get_y0(player_box) - rect_get_y0(tempRect2)
			if slideDelta > 0 and (rect_get_y0(player_box) <> rect_get_y0(tempHitbox))
			{
				y_slide_offset += slideDelta + 0.01
			}
		}
	}
	sync_player_co_with_box()
	//x = hitbox.getCentrex();
	//y = hitbox.y0 + heightOffset - ySlideOffset; // + heightOffset - ySlideOffset;
	//z = hitbox.getCentrez();
		
	xCollided = beginXD <> xDirection
		
	horizontal_collision = xCollided
	var verticalCollision = yDirection <> beginYD
	on_ground = verticalCollision and beginYD < 0
	
	var did_land = false
	if (on_ground)
	{
		if fall_distance > 0
		{
			did_land = true
			var ff = fall_distance - 3
			if fall_distance > 1
			{
				if ff > 0
				{
					audio_play_sound_at(pl_fallpain3, player_x, player_y, 0, 8, 16, 1, false, 1)
					player_fall_hurt_time = ceil(min(ff*0.25, timer.get_tps() * 4))
				}
				audio_play_sound_at(pl_jumpland2, player_x, player_y, 0, 8, 16, 1, false, 1)
			}
			//causeFallDamage(fallDistance);
			fall_distance = 0
		}
	}
	else if yDirection < 0
	{
		fall_distance -= yDirection
	}

	if xCollided
	{
		speed_x = 0
	}
	if verticalCollision
	{
		speed_y = 0
	}
	var diff_x = player_x - x_begin
	walk_dist += abs(diff_x) * 0.6
	if make_step_sounds
	{
		
		var bx = floor(player_x)
		var by = floor(player_y - 0.2)
		var onWhat = map.get_block(bx, by)
		//show_debug_message(onWhat)
		if walk_dist > next_step and onWhat <> global.air
		{
			next_step++;
			//var a4 = onWhat.properties.soundType();
			//if (!onWhat.getMaterial().isLiquid())
			if true
			{
				audio_play_sound_at(
					array_choose(step_sounds_generic),
					player_x,
					player_y,
					0,
					8,
					16,
					1,
					false,
					1
				)
				//level.playSoundFrom(this, a4.getPlaceSound(), a4.volume * 0.15f, a4.pitch);
			}
			//onWhat.onSteppedOn(level, new BlockCo(bx, by, bz));
		}
	}
}


///@self
function tick_player ()
{
	static temprect = rect_create(0,0,0,0)
	
	if player_fall_hurt_time > 0
	{
		player_fall_hurt_time -= 0.1
	}
	
	player_sneaking = wish_sneak > 0.5
	if player_sneaking <> player_was_sneaking
	{
		var nh = player_sneaking ? PLAYER_HEIGHT_SNEAKING : PLAYER_HEIGHT_STANDING
		if not player_try_change_height(nh)
		{
			player_sneaking = player_was_sneaking
		}
	}
	
	if player_sneaking
	{
		y_slide_offset += 0.2
		wish_xdirection *= 0.3
		if on_ground
		{
			player_superjump_charge++
		}
		
		if player_superjump_charge == 8
		{
			//audio_play_sound_at(sfx_lav_impact, player_x, player_y, 0, 8, 16, 1, false, 1)
		}
	}

	if on_ground
	{
		player_jump_coyote_time = floor(player_jump_coyote_time_max * timer.get_tps())
	}
	else
	{
		--player_jump_coyote_time
	}

	var superjump_ready = (player_superjump_charge - 8) > 0
	if (on_ground or player_jump_coyote_time > 0) and wish_ydirection <> 0
	{
		var jpower = 0.42
		var did_superjump = false
		if superjump_ready and player_was_sneaking and not player_sneaking
		{
			jpower *= 2
			player_superjump_charge = 0
			did_superjump = true
		}
		
		if array_length(map.get_colliders(rect_expand(player_box, 0, jpower))) <= 0
		{
			speed_y = jpower
			var sfx
			var pitch = 1
			if did_superjump
			{
				sfx = sfx_lav_fire
				pitch = 0.9
			}
			else if player_sneaking
			{
				sfx = pl_jump1
			}
			else
			{
				sfx = pl_jump2
			}
			
			audio_play_sound_at(sfx, player_x, player_y, 0, 8, 16, 1, false, 1, 0.6,0,pitch)
			player_jump_coyote_time = 0
		}
	}
	
	var ss = wish_xdirection * (on_ground ? 0.1 : 0.02)
	if abs(ss) >= 0.01
	{
		speed_x += ss
	}
	//moveRelative(x_direction, z_direction, onGround ? 0.1f : 0.02f);
	move(speed_x, speed_y)
	speed_x *= 0.91
	speed_y *= 0.98
	speed_y -= 0.08
	if on_ground
	{
		speed_x *= 0.6
	}
	
	var hmoment = min(speed_x, 0.1)
	var fallangle = 0
	if not on_ground
	{
		hmoment = 0
		fallangle = arctan(-speed_y * 0.2) * 15
	}
	player_bob += (hmoment-player_bob) * 0.4
	player_tilt += (fallangle-player_tilt) * 0.8
	
	if not player_sneaking
	{
		player_superjump_charge = 0
	}
}

