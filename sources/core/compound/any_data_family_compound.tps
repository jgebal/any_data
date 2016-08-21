create or replace type any_data_family_compound authid current_user under any_data(
   data_values     any_data_tab,
   overriding member function get_self_family_name return varchar2,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   overriding member procedure add_element( self in out nocopy any_data_family_compound, p_attribute any_data ),
   overriding member function get_element( p_position integer ) return any_data,
   overriding member function get_elements_count return integer,
   overriding member function compare_internal( p_other any_data ) return integer
) not final not instantiable;
/
