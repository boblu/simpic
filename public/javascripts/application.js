// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function toggle_seleced_list(){
	var cdt = document.getElementById('selected_all').checked;
	var all_checkboxes = document.getElementById('listing_body').getElementsByTagName('input');
//	var all_checkboxes = field_list;
	var set_value = false;
	if (cdt == false) { set_value = false; }
	else { set_value = true; }
	for (index in all_checkboxes) { all_checkboxes[index].checked = set_value; }
}