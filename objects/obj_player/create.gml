entity_variables();

state = player_state_free;

switch global.character
{
	case Character.JONAR:
	{
		health_max = 5;
		
		idle_animation             = spr_jonar_idle;
		walk_animation             = spr_jonar_walk;
		run_animation              = spr_jonar_run;
		switch_character_animation = spr_jonar_switch_character;
		
		hit_animation              = spr_jonar_hit;
		death_animation            = spr_jonar_die;
		
		walk_speed   = 3;
		run_speed	 = 8;
		acceleration = 0.5;
		deceleration = 1;
		
		attack_number = 3;
		attack_index  = 0;
		array_resize(attacks, attack_number);
		attacks[0] = new cmp_attack(spr_jonar_attack1, bb_jonar_attack1, sound_jonar_attack1, 1, 2, 10); // TODO(jonas): Make sure the 
		attacks[1] = new cmp_attack(spr_jonar_attack2, bb_jonar_attack2, sound_jonar_attack2, 1, 2, 15); // last numbers are right.
		attacks[2] = new cmp_attack(spr_jonar_attack3, bb_jonar_attack3, sound_jonar_attack3, 1, 2, 20);

		var dash_length = sprite_get_number(spr_jonar_dash) - 8;
		dash = new cmp_dash(spr_jonar_dash, bb_jonar_dash, sound_jonar_dash, 2, 12, dash_length);

		block = new cmp_block(spr_jonar_block, sound_jonar_block, 3);
	} break;
	
	case Character.JULLUS:
	{	
		health_max = 5;
		
		// @cleanup
		
		free.idle = spr_jullus_idle;
		walk_animation = spr_jullus_walk;
		run_animation = spr_jullus_run;
		switch_character_animation = spr_jullus_switch_character;
		hit_animation = spr_jullus_hit;

		// Is slower than Jonar.
		walk_speed   = 3;
		run_speed    = 8;
		acceleration = 0.3;
		deceleration = 0.4;

		charge_attack = new cmp_charge_attack(spr_jullus_attack, bb_jullus_attack, sound_jullus_charging, sound_jullus_release);
		duck          = new cmp_duck(spr_jullus_duck, sound_dab); // NOTE(jonas): sound_dab is placeholder.
		red           = new cmp_red(3);
	} break;
	
	_health = health_max;
}



