
//!#import rect.* in Rect

#macro MODE_OBJECT  0
#macro MODE_EDIT    1
#macro MODE_COMMAND 2

step_sounds_generic = get_sound_set("pl_step_generic") ///@is{array<sound>}

tick = method(self, function() /*=>*/ {
	player_xprevious = player_x
	player_yprevious = player_y
	rect_set_from(player_previous_box, player_box)
	tick_player()
})

timer = new Timer(20) ///@is {Timer}
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

cursor_x = 0
cursor_y = 0

palette = array_filter(global.blocks_all, function(bloc) /*=>*/ {return bloc.show_in_palette()}) ///@is{array<Block>}

current_paint = 0 ///@is{int}

player_x = 0 ///@is{number}
player_y = 0 ///@is{number}

player_xprevious = 0 ///@is{number}
player_yprevious = 0 ///@is{number}

player_wide = 0.6 ///@is{number}
player_tall = 1.8 ///@is{number}

player_box = rect_create(0,0,0,0) ///@is{Rect}
player_box_absolute = rect_create(0,0,0,0) ///@is{Rect}
player_previous_box = rect_create(0,0,0,0) ///@is{Rect}

player_eyeline = player_tall - 0.2

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

function sync_player_box_with_co ()
{
	rect_set_from(player_box, player_box_absolute)
	rect_move(player_box, player_x, player_y-height_offset+y_slide_offset)
}

function sync_player_co_with_box ()
{
	player_x = rect_get_centre_x(player_box)
	player_y = rect_get_y0(player_box) + height_offset - y_slide_offset
}

//update_player_co(map.wide * 0.5, map.tall)
update_player_co(map.wide * 0.5, 1.5, true)

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
	var broadPhase/*:array<Rect>*/ = map.get_colliders(rect_expand(player_box, xDirection, yDirection));
	
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

