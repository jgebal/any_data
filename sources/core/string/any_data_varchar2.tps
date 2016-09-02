create or replace type any_data_varchar2 authid current_user under any_data_family_string(
   data_value varchar2(32767),
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_varchar2( self in out nocopy any_data_varchar2, p_data varchar2 ) return self as result,
   overriding member function get_value_hash return raw
);
/
