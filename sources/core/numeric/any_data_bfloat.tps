create or replace
type any_data_bfloat authid current_user under any_data_family_numeric(
   data_value binary_float,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_bfloat( self in out nocopy any_data_bfloat, p_data binary_float ) return self as result
);
/
