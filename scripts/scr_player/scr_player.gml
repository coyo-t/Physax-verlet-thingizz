
#macro PLAYER_EYELINE_OFFSET (0.2)
#macro PLAYER_HEIGHT_STANDING (1.8)
#macro PLAYER_HEIGHT_SNEAKING (1.5-math_get_epsilon())
#macro PLAYER_RADIUS (0.6)

function Entity () constructor begin
	x/*:Number*/ = 0.0
	y/*:Number*/ = 0.0

	xprevious/*:Number*/ = 0.0
	yprevious/*:Number*/ = 0.0
	
	static tick = function ()
	{
	}
	
end


function Player () : Entity() constructor begin

	temp_adj_colliders = []
	temp_adj_check = rect_create(0,0,0,0)

	wide/*:Number*/ = PLAYER_RADIUS
	tall/*:Number*/ = PLAYER_HEIGHT_STANDING

	xspeed = 0
	yspeed = 0

	box = rect_create(0,0,0,0)
	box_absolute = rect_create(0,0,0,0)
	previous_box = rect_create(0,0,0,0)

	eyeline = tall - PLAYER_EYELINE_OFFSET

	bob = 0
	previous_bob = 0
	tilt = 0
	previous_tilt = 0

	jump_coyote_time_max = 2 * (1/20)
	jump_coyote_time = jump_coyote_time_max

	sneaking = false
	was_sneaking = false

	allow_jump_refire = 0

	fall_hurt_time = 0
	previous_fall_hurt_time = 0

	on_ground = false
	horizontal_collision = false
	collision = false
	height_offset = 0
	y_slide_offset = 0
	walk_dist = 0
	walk_dist_previous = 0
	fall_distance = 0
	foot_size = 0.6
	make_step_sounds = true
	next_step = 0


	///@self
	static update_co = function (_x/*:number*/, _y/*:number*/, _include_pev=false)
	{
		x = _x
		y = _y
		var hwide = wide * 0.5
		rect_set_corners(
			box_absolute,
			-hwide,
			0,
			+hwide,
			tall
		)
		sync_box_with_co()
	
		if _include_pev
		{
			xprevious = x
			yprevious = y
			rect_set_from(previous_box, box)
		}
	}

	///@self
	static sync_box_with_co = function (_box=undefined)
	{
		_box ??= box
		rect_set_from(_box, box_absolute)
		rect_move(_box, x, y-height_offset+y_slide_offset)
		eyeline = tall - PLAYER_EYELINE_OFFSET
		
	}

	///@self
	static sync_co_with_box = function ()
	{
		x = rect_get_centre_x(box)
		y = rect_get_y0(box) + height_offset - y_slide_offset
		eyeline = tall - PLAYER_EYELINE_OFFSET
	}

	///@self
	///@returns whether or not the new height could be changed to
	static try_change_height = function (_new_height/*:Number*/)/*->Boolean*/
	{
		static temp = rect_create(0,0,0,0)
		static temp2 = rect_create(0,0,0,0)
		static pred = function (_bloc, _shape, _x, _y)
		{
			return _bloc.is_solid()
		}
		if _new_height == tall
		{
			return true
		}
	
		if _new_height < tall
		{
			tall = _new_height
			rect_set_y1(box_absolute, _new_height)
			sync_box_with_co()
			return true
		}
	
		rect_set_from(temp, box_absolute)
		rect_set_y1(box_absolute, _new_height)
		sync_box_with_co(temp2)
		if array_length(Game.map.get_colliders(temp2, pred)) > 0
		{
			rect_set_from(box_absolute, temp)
			return false
		}
		tall = _new_height
		rect_set_y1(box_absolute, _new_height)
		sync_box_with_co()
		return true
	}

	///@self
	static is_inside_climbable = function ()
	{
		var xx = floor(x)
		var yy = floor(rect_get_y0(box))
		return Game.map.get_block(xx, yy).is_climbable()
	}
	
	///@self
	static move = function (xDirection/*:number*/, yDirection/*:number*/)
	{
		static TEMP_VEC = vec_create()
		temp_adj_colliders = []
		
		y_slide_offset *= 0.4
		var x_begin = x
		
		var beginXD = xDirection;
		var beginYD = yDirection;
		//{
		//	var modv = trySneakClip(tempvec1.set(xDirection, yDirection, zDirection));
		//	xDirection = beginXD = modv.x;
		//	yDirection = beginYD = modv.y;
		//}
		
		var ORIGINAL_BOX = rect_copy_temp(box)
		var tempHitbox = rect_copy_temp(box)
		
		var broadPhase = Game.map.get_colliders(rect_expand(rect_copy_temp(box), xDirection, yDirection));
		var br_length = array_length(broadPhase)
		begin
			// y axis
			for (var i = 0; i < br_length;)
			{
				yDirection = rect_clip_y_collide(broadPhase[i++], box, yDirection)
			}
			rect_move(box, 0, yDirection)

			
			// x axis
			for (var i = 0; i < br_length;)
			{
				xDirection = rect_clip_x_collide(broadPhase[i++], box, xDirection)
			}
			rect_move(box, xDirection, 0)
		
		end
		var xCollided = beginXD <> xDirection
		var yCollided = beginYD <> yDirection
		var hitGround = on_ground or (yCollided and beginYD < 0)
		
		// if we've horizontally collided, try to see if we can go further by moving by
		// our "foot size" (how tall of a step we can walk up)
		if foot_size > 0 and hitGround and (on_ground or y_slide_offset < 0.05) and xCollided
		{
			var bx = xDirection
			var by = yDirection
			xDirection = beginXD
			yDirection = foot_size
			
			var tempRect2 = rect_copy_temp(box)
			rect_set_from(box, tempHitbox)
			var broad = Game.map.get_colliders(rect_expand(rect_copy_temp(box), xDirection, yDirection))
			var bcount = array_length(broad)
			for (var i = bcount; i > 0;)
			{
				yDirection = rect_clip_y_collide(broad[--i], box, yDirection)
			}
			rect_move(box, 0, yDirection)
		
			for (var i = bcount; i > 0;)
			{
				xDirection = rect_clip_x_collide(broad[--i], box, xDirection)
			}
			rect_move(box, xDirection, 0)
		
			{
				yDirection = -foot_size
				// This isnt very efficent, but it should solve the issue of very occasionally
				// missing a block when upstepping after hitting our head in the above steps
				// (and thusly bogusly setting our hitbox to be clipping into it when moving down here)
			
				var ttmp = Game.map.get_colliders(rect_expand(rect_copy_temp(box), bx, yDirection))
				for (var i = array_length(ttmp); i > 0;)
				{
					yDirection = rect_clip_y_collide(ttmp[--i], box, yDirection)
				}
				rect_move(box, 0, yDirection)
			}

			if abs(bx) >= abs(xDirection)
			{
				xDirection = bx
				yDirection = by
				rect_set_from(box, tempRect2)
			}
			else
			{
				// If we're sliding a small distance, dont add to yslideofs
				// this is to mask the jitters from walking across a corner like this:
				// Xx (x is the floor, X is 1 block above)
				// x
				var slideDelta = rect_get_y0(box) - rect_get_y0(tempRect2)
				if slideDelta > 0 and (rect_get_y0(box) <> rect_get_y0(tempHitbox))
				{
					y_slide_offset += slideDelta + 0.01
				}
			}
		}
		sync_co_with_box()
		//x = hitbox.getCentrex();
		//y = hitbox.y0 + heightOffset - ySlideOffset; // + heightOffset - ySlideOffset;
		//z = hitbox.getCentrez();
		
		xCollided = beginXD <> xDirection
		yCollided = beginYD <> yDirection
		
		horizontal_collision = xCollided
		on_ground = yCollided and beginYD < 0
	
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
						audio_play_sound_at(pl_fallpain3, x, y, 0, 8, 16, 1, false, 1)
						fall_hurt_time = ceil(min(ff*0.25, Game.timer.get_tps() * 4))
					}
					audio_play_sound_at(pl_jumpland2, x, y, 0, 8, 16, 1, false, 1)
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
			xspeed = 0
		}
		if yCollided
		{
			yspeed = 0
		}
		var diff_x = x - x_begin
		walk_dist += abs(diff_x) * 0.6
		if make_step_sounds
		{
		
			var bx = floor(x)
			var by = floor(y - 0.2)
			var onWhat = Game.map.get_block(bx, by)
			//show_debug_message(onWhat)
			if walk_dist > next_step and onWhat <> global.air
			{
				next_step++;
				var st = onWhat.sound_type
				//var a4 = onWhat.properties.soundType();
				//if (!onWhat.getMaterial().isLiquid())
				if true
				{
					var sss = array_choose(st.step_sound)
					var sfx = audio_play_sound_at(sss, x, y, 0, 8, 16, 1, false, 1)
					audio_sound_gain(sfx, st.gain, 0)
					audio_sound_pitch(sfx, st.pitch)
					//level.playSoundFrom(this, a4.getPlaceSound(), a4.volume * 0.15f, a4.pitch);
				}
				//onWhat.onSteppedOn(level, new BlockCo(bx, by, bz));
			}
		}
	
		var xsign = sign(beginXD)
		var ysign = sign(beginYD)
	
		var closure = {
			occupy: rect_get_temp(
				floor(rect_get_x0(box)),
				floor(rect_get_y0(box)),
				floor(rect_get_x1(box)+1),
				floor(rect_get_y1(box)+1)
			),
			pb: box,
		}
		var check = rect_expand(rect_copy_temp(box), xsign, ysign)
		temp_adj_colliders = Game.map.get_colliders(
			check,
			method(closure, function (_bloc, _shape, _x, _y) {
				var p = pb
				return (
					rect_get_y1(_shape) == rect_get_y0(p) and
					rect_get_x0(_shape) < rect_get_x1(p) and
					rect_get_x1(_shape) > rect_get_x0(p)
				)
		}))
		array_insert(temp_adj_colliders, 0, check, closure.occupy)
	}

	///@self
	static update_pev = function ()
	{
		xprevious = x
		yprevious = y
		previous_bob = bob
		walk_dist_previous = walk_dist
		previous_tilt = tilt
		previous_fall_hurt_time = fall_hurt_time
		was_sneaking = sneaking
		rect_set_from(previous_box, box)
	}

	///@self
	static tick = function ()
	{
	
		update_pev()
	
		var wish_xd = Game.wish_xdirection
	
		if fall_hurt_time > 0
		{
			fall_hurt_time -= 0.1
		}
	
		sneaking = Game.wish_sneak > 0.5
		if sneaking <> was_sneaking
		{
			var nh = sneaking ? PLAYER_HEIGHT_SNEAKING : PLAYER_HEIGHT_STANDING
			if not try_change_height(nh)
			{
				sneaking = was_sneaking
			}
		}
	
		if sneaking
		{
			y_slide_offset += 0.2
			if on_ground
			{
				wish_xd *= 0.3
			}
		}

		if on_ground
		{
			jump_coyote_time = floor(jump_coyote_time_max * Game.timer.get_tps())
		}
		else
		{
			--jump_coyote_time
		}
		if (on_ground or jump_coyote_time > 0) and Game.wish_ydirection <> 0
		{
			var jpower = 0.42
			//TODO:THIS
			if true//array_length(map.get_colliders(rect_expanded(player_box, 0, 0.01))) <= 0
			{
				yspeed = jpower
				var sfx
				var pitch = 1

				if sneaking
				{
					sfx = pl_jump1
				}
				else
				{
					sfx = pl_jump2
				}
			
				audio_play_sound_at(sfx, x, y, 0, 8, 16, 1, false, 1, 0.6,0,pitch)
				jump_coyote_time = 0
			}
		}
	
		var basis = .91
		if on_ground
		{
			var bx = floor(x)
			var by = floor(y - 1)
			var onWhat = Game.map.get_block(bx, by)
			basis *= onWhat.ground_slipperiness
		}
	
		basis = power(0.6 * 0.91, 3) / power(basis, 3)
		var ss = wish_xd * (on_ground ? 0.1 * basis: 0.02)
		if abs(ss) >= 0.01
		{
			xspeed += ss
		}
		//moveRelative(x_direction, z_direction, onGround ? 0.1f : 0.02f);
	
		var screw_gravity = false
		if is_inside_climbable()
		{
			fall_distance = 0
			yspeed = max(yspeed, -0.15)
		}
	
		var ground_frict = 0.91
		if on_ground
		{
			var bx = floor(x)
			var by = floor(y - 1)
			var onWhat = Game.map.get_block(bx, by)
			ground_frict *= onWhat.ground_slipperiness
		}
	
		move(xspeed, yspeed)
	
		if is_inside_climbable()
		{
			if Game.wish_sneak > 0
			{
				yspeed = 0
				screw_gravity = true
			}
			if horizontal_collision or Game.wish_ydirection <> 0
			{
				yspeed = 0.2
				screw_gravity = false
			}
		}
	
		if not screw_gravity
		{
			yspeed -= 0.08
		}
	
		xspeed *= ground_frict//0.91
		yspeed *= 0.98
	
		var hmoment = min(xspeed, 0.1)
		var fallangle = 0
		if not on_ground
		{
			hmoment = 0
			fallangle = arctan(-yspeed * 0.2) * 15
		}
		bob += (hmoment-bob) * 0.4
		tilt += (fallangle-tilt) * 0.8
	
	}

end
