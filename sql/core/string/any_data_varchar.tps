create or replace type any_data_varchar authid current_user under any_data_family_string(
   data_value varchar(32767),
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_varchar( self in out nocopy any_data_varchar, p_data varchar ) return self as result
);
/
