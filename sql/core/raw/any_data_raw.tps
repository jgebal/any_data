create or replace type any_data_raw authid current_user under any_data_family_raw(
   data_value raw(32767),
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_raw( self in out nocopy any_data_raw, p_data raw ) return self as result
);
/
