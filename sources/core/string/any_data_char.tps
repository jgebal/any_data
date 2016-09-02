create or replace type any_data_char authid current_user under any_data_family_string(
   data_value varchar2(32767),
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_char( self in out nocopy any_data_char, data_value varchar2 ) return self as result,
   constructor function any_data_char( self in out nocopy any_data_char, type_code number, type_name varchar2, self_type_name varchar2, data_value varchar2 ) return self as result,
   overriding member function get_value_hash return raw
);
/
