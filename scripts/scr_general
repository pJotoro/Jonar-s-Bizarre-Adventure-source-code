function draw_set_text(_color, _font, _halign, _valign) 
{
	draw_set_color(_color);
	draw_set_font(_font);
	draw_set_halign(_halign);
	draw_set_valign(_valign);
}

// I don't need all these param comments anymore but at the same time that information might come in handy later.

// animation_end(sprite_index, image_index, rate)
// <sprite_index> The index of the sprite being animated
// <image_index> The current frame value
// <rate> -See Below-
// The rate of change in frames per step if not
// using built in image_index/image_speed.  
// Don't use if you don't think you need this.  You probably don't.
function animation_end() 
{
	/*returns true if the animation will loop this step.
 
	//Script courtesy of PixellatedPope & Minty Python from the GameMaker subreddit discord
	/https:////www.reddit.com/r/gamemaker/wiki/discord

	*/
 
	var _sprite = sprite_index,
		_image  = image_index;
	
	if argument_count > 0 _sprite = argument[0];
	if argument_count > 1 _image  = argument[1];

	var _type = sprite_get_speed_type(sprite_index),
		_spd = sprite_get_speed(sprite_index) * image_speed;
	
	if _type == spritespeed_framespersecond _spd = _spd/room_speed;
	if argument_count > 2 _spd = argument[2];

	return _image + _spd >= sprite_get_number(_sprite);
}

function collision() 
{
	// As well as collisions, this script can also be used to check for if the object is colliding with anything.
	
	// collision vars
	var x_touching_ground = place_meeting(x + x_velocity, y, obj_collision);
	var	y_touching_ground = place_meeting(x, y + y_velocity, obj_collision);
	var	collided = undefined;
	
	// collisions
	if x_touching_ground 
	{
		collided = true; // collided with something
		while !x_touching_ground x += past_x_direction 
		x_velocity = 0;	
	} 
	
	if y_touching_ground 
	{	
		collided = true; // collided with something
		while !y_touching_ground y += past_y_direction
		y_velocity = 0;	
	} 

	if collided != true collided = false; // didn't collide with anything
	return collided;
}

//function hit(_object_hitting) 
//{
//	// I hate this code.
//	// I tried removing it but it didn't work for some reason.

//	var hurtbox = instance_create_layer(x, y, layer, obj_hurtbox);

//	hurtbox.mask_index = attack_mask;
//	hurtbox.hitting_object = place_meeting(x, y, _object_hitting);

//	if hurtbox.hitting_object && on_attack_image
//	{
//		instance_destroy(hurtbox);
//		return true;
//	}
//	else
//	{
//		instance_destroy(hurtbox);
//		return false;
//	}
//}

function flash(_flash_speed) 
{
	if _flash > 0 
	{
		// used to make the player stay at the same level of flash during freeze effect
		if !global.freeze_frame  _flash -= _flash_speed; 
	
		shader_set(sh_flash);
	
		shade_alpha = shader_get_uniform(sh_flash, "alpha");
		shader_set_uniform_f(shade_alpha, _flash);

		draw_self();
		shader_reset();
	} 
}

function sec(_number_of_seconds) 
{
	// script multiplies input by 60 so that it becomes seconds
	return 60 * _number_of_seconds;
}

function start_game() 
{
	// TODO(jonas): Change the room order so that this function doesn't need to exist anymore??? That might be too much
	// work though...
	room = rm_cutscene1_scene1;
}

function end_game() 
{
	// This is a piece of garbage but I can't get rid of it because GameMaker is garbage!
	game_end();
}

function change_music(_music) 
{
	audio_stop_sound(global.music);
	global.music = _music;
	audio_play_sound(global.music, 1, true);
}
