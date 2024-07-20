
#macro MODE_OBJECT  0
#macro MODE_EDIT    1
#macro MODE_COMMAND 2

///@type {Array<Asset.GMSound}
step_sounds_generic = tag_get_asset_ids("pl_step_generic", asset_sound)

tick = method(self, function () {
	player_xprevious = player_x
	player_yprevious = player_y
	player_previous_box.set_from(player_box)
	tick_player()
})

///@type {Struct.Timer}
timer = new Timer(20)
timer.time_scale = 1

///@type {Struct.Rect}
tempHitbox = new Rect(0,0,0,0)

///@type {Struct.Rect}
tempRect2 = new Rect(0,0,0,0)


///@type {Struct.Map}
map = new Map(16, 8)

///@type {Struct.Camera}
cam = new Camera()

cam.x = map.wide / 2
cam.y = map.tall / 2

m_view = matrix_build_identity()
m_proj = matrix_build_identity()
m_inv_proj_view = matrix_build_identity()

cursor_x = 0
cursor_y = 0

///@type {Array<Struct.Block>}
palette = array_filter(global.blocks_all, function (bloc) {
	return bloc.show_in_palette()
})

current_paint = 0

///@type {Real}
player_x = 0

///@type {Real}
player_y = 0

player_xprevious = 0
player_yprevious = 0

///@type {Real}
player_wide = 0.6

///@type {Real}
player_tall = 1.8

///@type {Struct.Rect}
player_box = new Rect(0,0,0,0)

///@type {Struct.Rect}
player_box_absolute = new Rect(0,0,0,0)

///@type {Struct.Rect}
player_previous_box = new Rect(0,0,0,0)

allow_jump_refire = 0

slide = true

wish_xdirection = 0
wish_ydirection = 0

on_ground = false
horizontal_collision = false
collision = false
height_offset = 0
y_slide_offset = 0
walk_dist = 0
speed_x = 0
speed_y = 0
fall_distance = 0
foot_size = 0.6
make_step_sounds = true
next_step = 0

function update_player_co (_x, _y, _include_pev=false)
{
	player_x = _x
	player_y = _y
	var hwide = player_wide * 0.5
	player_box_absolute.set_corners(
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
		player_previous_box.set_from(player_box)
	}
}

function sync_player_box_with_co ()
{
	player_box
	.set_from(player_box_absolute)
	.move(player_x, player_y-height_offset+y_slide_offset)
}

function sync_player_co_with_box ()
{
	player_x = (player_box.x0 + player_box.x1) * 0.5
	player_y = player_box.y0 + height_offset - y_slide_offset
}

//update_player_co(map.wide * 0.5, map.tall)
update_player_co(map.wide * 0.5, 1.5, true)

///@func move
///@arg {Real} delta_x
///@arg {Real} delta_y
function move (xDirection, yDirection)
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
	
	tempHitbox.set_from(player_box);
	var broadPhase = map.get_colliders(player_box.expand(xDirection, yDirection));
		
	// y axis
	for (var i = 0; i < array_length(broadPhase);)
	{
		var box = broadPhase[i++]
		yDirection = box.clip_y_collide(player_box, yDirection)
	}
	player_box.move(0, yDirection)
		
	var hitGround = on_ground or (yDirection <> beginYD && beginYD < 0)
		
	// x axis
	for (var i = 0; i < array_length(broadPhase);)
	{
		var box = broadPhase[i++]
		xDirection = box.clip_x_collide(player_box, xDirection)
	}
	player_box.move(xDirection, 0)
	
	var xCollided = beginXD <> xDirection

	// if we've horizontally collided, try to see if we can go further by moving by
	// our "foot size" (how tall of a step we can walk up)
	if foot_size > 0 and hitGround and (on_ground or y_slide_offset < 0.05) and (xCollided)
	{
		var bx = xDirection
		var by = yDirection
		xDirection = beginXD
		yDirection = foot_size
		
		tempRect2.set_from(player_box);
		player_box.set_from(tempHitbox);
		var cubz = map.get_colliders(player_box.expand(xDirection, yDirection))
		
		for (var i = 0; i < array_length(cubz);)
		{
			var box = cubz[i++]
			yDirection = box.clip_y_collide(player_box, yDirection)
		}
		player_box.move(0, yDirection)

		for (var i = 0; i < array_length(cubz);)
		{
			var box = cubz[i++]
			xDirection = box.clip_x_collide(player_box, xDirection)
		}
		player_box.move(xDirection, 0)

		{
			yDirection = -foot_size
			// This isnt very efficent, but it should solve the issue of very occasionally
			// missing a block when upstepping after hitting our head in the above steps
			// (and thusly bogusly setting our hitbox to be clipping into it when moving down here)
			var bogus = map.get_colliders(player_box.expand(bx, yDirection))
			for (var i = 0; i < array_length(bogus);)
			{
				var box = bogus[i++]
				yDirection = box.clip_y_collide(player_box, yDirection)
			}
			player_box.move(0, yDirection);
		}

		if abs(bx) >= abs(xDirection)
		{
			xDirection = bx;
			yDirection = by;
			player_box.set_from(tempRect2);
		}
		else
		{
			// If we're sliding a small distance, dont add to yslideofs
			// this is to mask the jitters from walking across a corner like this:
			// Xx (x is the floor, X is 1 block above)
			// x
			var slideDelta = player_box.y0 - tempRect2.y0
			if slideDelta > 0 and (player_box.y0 <> tempHitbox.y0)
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

previous_wish_ydirection = 0
function tick_player ()
{
	var do_refire_check = wish_ydirection == previous_wish_ydirection
	if not do_refire_check
	{
		allow_jump_refire = 0
	}
	previous_wish_ydirection = wish_ydirection
	if on_ground and (--allow_jump_refire <= 0) and wish_ydirection <> 0 
	{
		speed_y = 0.42
		audio_play_sound_at(pl_jump2, player_x, player_y, 0, 8, 16, 1, false, 1)
		//allow_jump_refire = floor(timer.get_tps() * 0.25)
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
}

