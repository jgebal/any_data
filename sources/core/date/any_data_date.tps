create or replace type any_data_date authid current_user under any_data_family_date(
   data_value date,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_date( self in out nocopy any_data_date, p_data date ) return self as result
);
/
