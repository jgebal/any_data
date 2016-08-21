create or replace type any_data_blob authid current_user under any_data_family_raw(
   data_value blob,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_blob( self in out nocopy any_data_blob, p_data blob ) return self as result
);
/
