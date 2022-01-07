// NOTE(jonas): If you see any comments saying "inputting" it's because I'm a fucking idiot lol.

enum Character
{
	JONAR,
	JULLUS
}

global.character = Character.JONAR;

function attack_process()
{
	var a = argument[0];
	var _set_animation;
	if argument_count > 1  _set_animation = argument[1];
	else _set_animation = true;
	
	if sprite_index != a.animation
	{
		// NOTE(jonas): If I don't want the animation to be set inside attack_process, I can specify so (right now this is only 
		// useful for the dash but I could see this also being useful for any attack where you want the animation to be set 
		// separately from when you can hit enemies).
		if _set_animation
		{
			sprite_index = a.animation;
			image_index = 0;
		}
		
		ds_list_clear(hit_by_attack);
	}

	past_image_index = floor(image_index);

	attacking = true; // This will be remembered for after the freeze frame ends.

	mask_index = a.hitbox;

	var hit_by_attack_now = ds_list_create();
	var hits = instance_place_list(x, y, obj_gremlin, hit_by_attack_now, false);
	
	log(hit_by_attack_now);
	log(hits);
	
	for (var i = 0; i < hits; i++)
	{
		if hits > 0
		{
			var hit_id = hit_by_attack_now[| i];
			if ds_list_find_index(hit_by_attack, hit_id) == -1 && hit_id._health > 0
			{
				state = player_state_freeze_frame;
			
				// game object
				global.freeze_frame = true;
				game.alarm[0] = a.pause_length;
			
				// enemy
				ds_list_add(hit_by_attack, hit_id);
				with hit_id
				{
					sprite_index = hit_animation;
				
					_flash = 0.75;
				
					// freeze frame
					state = enemy_state_freeze_frame;
					past_image_index = floor(image_index); // reverse is done inside freeze frame script
					hit = true;
				
					// health
					_health -= a.damage;
					alarm[1] = sec(3); // healthbar timer
				}
			}
		}
	}

	ds_list_destroy(hit_by_attack_now);
	mask_index = idle_animation;
}

function player_state_attack_combo()
{
	var a = attacks[attack_index];
	
	// Changed version of attack_process.
	// TODO(jonas): Move this stuff back to attack_process.
	{
		if sprite_index != a.animation
		{
			sprite_index = a.animation;
			image_index = 0;
		
			ds_list_clear(hit_by_attack);
		}

		past_image_index = floor(image_index);

		attacking = true; // This will be remembered for after the freeze frame ends.

		mask_index = a.hitbox;

		var hit_by_attack_now = ds_list_create();
		var hits = instance_place_list(x, y, enemies, hit_by_attack_now, false);
		
		for (var i = 0; i < ds_list_size(hit_by_attack_now); i++)
		{
			if hits > 0
			{
				var hit_id = hit_by_attack_now[| i];
				if ds_list_find_index(hit_by_attack, hit_id) == -1 && hit_id._health > 0
				{
					state = player_state_freeze_frame;
			
					// game object
					global.freeze_frame = true;
					game.alarm[0] = a.pause_length;
			
					// enemy
					ds_list_add(hit_by_attack, hit_id);
					with hit_id
					{
						sprite_index = hit_animation;
				
						_flash = 0.75;
				
						// freeze frame
						state = enemy_state_freeze_frame;
						past_image_index = floor(image_index); // reverse is done inside freeze frame script
						hit = true;
				
						// health
						_health -= a.damage;
						alarm[1] = sec(3); // healthbar timer
					}
				}
			}
		}

		ds_list_destroy(hit_by_attack_now);
		
	}

	// move
	if image_index <= a.image_stop
	{
		var dir	= point_direction(0, 0, past_x_direction, y_direction);
	
		x_velocity = lengthdir_x(0.5, dir);
		y_velocity = lengthdir_y(0.375, dir);
	
		collision();
	
		x += x_velocity;
		y += y_velocity;
	}
	
	var attacking_again = keyboard_check_pressed(global.key_attack) && !keyboard_check(global.key_run) 
	&& attack_index < (attack_number-1);
	if attacking_again  attack_index += 1; // trigger combo chain	

	alarm[1] = sec(0.5);

	if animation_end() 
	{
		state = player_state_free;
		if attack_index < attack_number-1  attack_index += 1;
		else attack_index = 0;
		attacking = false;
		
		mask_index = idle_animation; // NOTE(jonas): Moved from edited version of attack_process.
	}
}

// TODO(jonas): Change these stupid parameters.
function player_state_charge_attack() 
{	
	if sprite_index != charge_attack.animation
	{
		sprite_index = charge_attack.animation;
		image_index = 0;
		mask_index = spr_empty;
		audio_play_sound(charge_attack.sound_charging, 1, false);
	
		// set speed to 0
		x_velocity = 0;
		y_velocity = 0;
	}

	if !charge_attack.releasing
	{
		if not keyboard_check(global.key_attack) // switch to releasing attack
		{
			charge_attack.releasing = true;
			audio_stop_sound(charge_attack.sound_charging);
			audio_play_sound(charge_attack.sound_release, 1, false);
			image_index = 1;
			mask_index = charge_attack.hitbox;
		}
		else // charging attack
		{
			charge_attack.frames += 1;
			
			function update_charge_attack(_charge_attack_damage, _timer_increment)
			{
				charge_attack.damage = _charge_attack_damage;
				
				// update red shader
				red.timer += _timer_increment;
				red.amount = clamp(sin(timer * 0.05) * red.max_strength, 
				0, red.max_strength); // clamped so it doesn't go negative
				show_debug_message(red.amount);
			}
			
			switch charge_attack.frames
			{ // 1,2 2,3 5,4
				// TODO(jonas): In the case that multiple characters get charge attacks, it would be cool if I could just put in a
				// bunch of arrays and it just automatically works.
				case 30:  update_charge_attack(1, 2); break;
				case 60:  update_charge_attack(2, 3); break;
				case 120: update_charge_attack(5, 4); break;
			}
		}
	}
	else // releasing charge attack
	{
		attack_process(charge_attack);
		if alarm_off(4)  alarm[4] = 15;
	}
}

function player_state_dash() 
{
	if sprite_index != dash.animation
	{
		sprite_index = dash.animation;
		image_index = 0;
	}
	
	var dir	= point_direction(0, 0, x_direction, y_direction);

	if floor(image_index) < dash.length_
	{	
		if !audio_is_playing(dash.sound)  audio_play_sound(dash.sound, 1, false);
		dashing = true; // Exists so the thrown gremlin can take the right amount of damage.
		attack_process(dash);

		// Continue moving in whatever direction the player was moving in before.
		x_velocity = lengthdir_x(dash.speed_, dir);
		y_velocity = lengthdir_y(dash.speed_, dir);
		
		x_velocity += x_direction * 2.5;
		y_velocity += y_direction * 2.5;
	} 
	else 
	{
		dashing = false;
	
		// chain dash
		if keyboard_check(global.key_run) && (x_direction != false || y_direction != false)
		&& keyboard_check_pressed(global.key_attack)
		{	
			image_index = 0;
		
			// Take in new input in case the player is actually pressing the arrow keys.
			x_direction = keyboard_check(vk_right) - keyboard_check(vk_left);
			y_direction = keyboard_check(vk_down) - keyboard_check(vk_up);
		
			ds_list_clear(hit_by_attack); // Clear all enemies that have already been hit.
		}
	
		// Continue inputting in whatever direction the player was inputting in before.
		x_velocity = lengthdir_x(0.5, dir);
		y_velocity = lengthdir_y(0.5, dir);
	} 

	// move
	x += x_velocity;
	y += y_velocity;

	if collision() 
	{
		state = player_state_dizzy; // Dashing into a wall caused the player to become dizzy.
		attacking = false;
		dashing = false;
	}
	else if animation_end() 
	{
		state = player_state_free;
		alarm[3] = sec(0.5); // dash attack delay
		attacking = false;
		dashing = false;
	}
}

function state_block() 
{
	if sprite_index != block.animation
	{
		sprite_index = block.animation;
		image_index = 0;
		mask_index = normal_mask_index; // allows for the enemies to be able to hit you
	}
	if not audio_is_playing(block.sound)  audio_play_sound(block.sound, 1, false);

	if image_index >= 1 && image_index <= 5  blocking = true;
	else blocking = false;

	if animation_end(spr_jonar_block) 
	{
		state = player_state_free;
		blocking = false;
		attacking = false;
	}
}

function player_state_dizzy() 
{
	// TODO(jonas): Redo dizzy.
	state = player_state_free;
	//// Dizzy time is the number of times that the dizzy animation plays. Once it reaches 3, the player stops being dizzy.

	//// Maybe this should happen when the state gets set?
	//if sprite_index != dizzy.animation
	//{
	//	sprite_index = dizzy.animation;
	//	image_index = 0;
	//}

	//// There is a weird ass issue where the variable gets incremented twice in a split second for no reason. As a result, 0.5
	//// to be added instead of 1 so that way the animation can play three times.
	//if animation_end(dizzy.animation) dizzy.time += 0.5;

	//// if animation has played three times stop being dizzy
	//if (dizzy.time == 3)
	//{
	//	dizzy.time = 0;
	//	state = player_state_free;
	
	//	// charge attack stuff
	//	// NOTE(jonas): The player gets dizzy after dashing into a wall so the code below ends the dash.
	//	// This stuff makes no goddamn sense. Maybe in the future it would be a good idea to make a procedure that automatically
	//	// resets attack variables so that way I don't have to do shit like this all the goddamn time.
	//	charge_attack.released = false;
	//	alarm[6] = -1;
	//	// Set charge attack damage to 0 here.
	//}
}

// TODO(jonas): Put this inside one state_block?
function state_duck() 
{
	if sprite_index != block.animation
	{
		sprite_index = block.animation;
		mask_index = spr_empty;
		image_index = 0;
	}

	if not keyboard_check(ord("C")) 
	{
		mask_index = idle_animation;
		state = player_state_free;
	}
}

function player_state_freeze_frame() 
{
	image_index = past_image_index;
	if alarm[1] > -1  alarm[1] += 1;
	if alarm[2] > -1  alarm[2] += 1;
	if not global.freeze_frame 
	{
		if health <= 0 
		{ 
			state = state_die; 
			game.alarm[3] = -1; // Prevents the player healthbar from showing up while the screen fades out.
		}

		else if dashing                                            state = player_state_dash;
		else if attacking && global.character == Character.JONAR   state = player_state_attack_combo;
		else if attacking && global.character == Character.JULLUS  state = player_state_charge_attack;
		else                                                       state = player_state_free;
	}
}

function player_state_free() 
{
	// TODO(jonas): Make a global switch character button?
	if keyboard_check_pressed(vk_space)  global.character = Character.JONAR // @cleanup
	else
	{
		// Get input. TODO(jonas): Could it be a good idea to just get input in one central function or something?
		var left  = keyboard_check(global.key_left);
		var right = keyboard_check(global.key_right);
		var down  = keyboard_check(global.key_down);
		var up    = keyboard_check(global.key_up);
		var attack = keyboard_check_pressed(global.key_attack);
		var block  = keyboard_check_pressed(global.key_block);
		
		x_direction = right - left;
		if x_direction != 0  past_x_direction = x_direction;
		image_xscale = past_x_direction;
		y_direction = down - up;
		if y_direction != 0 past_y_direction = y_direction;
		
		var inputting;
		if (x_direction != 0) || (y_direction != 0)  inputting = true;
		else inputting = false;
		var moving_horizontally = x_velocity != 0;
		var moving_vertically   = y_velocity != 0;
		var moving = inputting || (moving_horizontally || moving_vertically);
		
		var running;
		if moving && keyboard_check(global.key_run)  running = true;
		else running = false;
		
		if attack
		{
			if !running  
			{
				if      global.character == Character.JONAR   state = player_state_attack_combo;
				else if global.character == Character.JULLUS  state = player_state_charge_attack;
			}
			else state = player_state_dash;
		}
		else if block  state = state_block;
		else
		{	
			function x_velocity_decrease()
			{
				if past_x_direction == 1 
				{
					x_velocity -= deceleration;
					if x_velocity <= 0  x_velocity = 0;
				}
				else if past_x_direction == -1
				{
					x_velocity += deceleration;
					if x_velocity >= 0  x_velocity = 0;
				}
			}
			
			function y_velocity_decrease()
			{
				if past_y_direction == 1 
				{
					y_velocity -= deceleration;
					if y_velocity <= 0  y_velocity = 0;
				}
				else if past_y_direction == -1
				{
					y_velocity += deceleration;
					if y_velocity >= 0  y_velocity = 0;
				}
			}
			
			function update_velocity()
			{
				var acceleration_multiplier;
				if argument_count > 0  acceleration_multiplier = argument[0];
				else acceleration_multiplier = 1;
				
				if x_direction != 0  x_velocity += x_direction * (acceleration*acceleration_multiplier);
				else  x_velocity_decrease();
				if y_direction != 0  y_velocity += y_direction * (acceleration*acceleration_multiplier);
				else  y_velocity_decrease();
			}
			
			function cap_velocity(s)
			{
				if place_meeting(x, y, obj_grass)  s /= 2;
				x_velocity = clamp(x_velocity, -s, s);
				y_velocity = clamp(y_velocity, -s, s);
			}
		
			if !running && moving
			{
				if sprite_index != walk_animation
				{
					sprite_index = walk_animation;
					image_index  = 0;
				}

				update_velocity();
				cap_velocity(walk_speed);
			}
			else if running
			{
				if sprite_index != run_animation
				{
					sprite_index = run_animation;
					image_index  = 0;
				}
				
				update_velocity(2);
				cap_velocity(run_speed);
			}
			else if !moving && sprite_index != idle_animation
			{
				sprite_index = idle_animation;
				image_index  = 0;
			}
			
			collision();
				
			// Move.
			x += x_velocity;
			y += y_velocity;
		}
	}
}
