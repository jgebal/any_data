create or replace type any_data_interval_ym authid current_user under any_data(
   data_value yminterval_unconstrained,
   overriding member function get_self_family_name return varchar2,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_interval_ym( self in out nocopy any_data_interval_ym, p_data yminterval_unconstrained ) return self as result
);
/
