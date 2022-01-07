function red_shader(_max_strength) constructor
{
	red = 0;
	red_amount =   0;
	timer =        0;
	max_strength = _max_strength;
	sh_handle =    shader_get_uniform(sh_addRed, "red_amount");
}
