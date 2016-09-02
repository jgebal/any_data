create or replace type any_data_clob authid current_user under any_data_family_string(
   data_value clob,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_clob( self in out nocopy any_data_clob, p_data clob ) return self as result,
   overriding member function get_value_hash return raw
);
/
