create or replace type any_data_bdouble authid current_user under any_data_family_numeric(
   data_value binary_double,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_bdouble( self in out nocopy any_data_bdouble, p_data binary_double ) return self as result
);
/
