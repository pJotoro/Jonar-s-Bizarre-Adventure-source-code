function log(_variable) 
{
	show_debug_message(string(_variable));
}

function draw_variable(_variable_name_as_string) 
{
	var y_offset = y - y_top_variable + (variable_count * 15);
	variable_count += 1;
	var variable_value = string(variable_instance_get(id, _variable_name_as_string));
	draw_text(x, y_offset, _variable_name_as_string + ": " + variable_value);
}
