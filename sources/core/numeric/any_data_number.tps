create or replace type any_data_number authid current_user under any_data_family_numeric(
   data_value number,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_number( self in out nocopy any_data_number, p_data number ) return self as result
);
/
