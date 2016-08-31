create or replace type any_data_family_compound authid current_user under any_data(
   data_values     any_data_tab,
   overriding member function get_self_family_name return varchar2,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   overriding member function get_elements_count return integer,
   member procedure set_data_values(self in out nocopy any_data_family_compound, p_data_values any_data_tab),
   overriding member function compare_internal( p_other any_data ) return integer
) not final not instantiable;
/
