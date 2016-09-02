create or replace type any_data_interval_ds authid current_user under any_data(
   data_value dsinterval_unconstrained,
   overriding member function get_self_family_name return varchar2,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_interval_ds( self in out nocopy any_data_interval_ds, p_data dsinterval_unconstrained ) return self as result,
   overriding member function get_value_hash return raw
);
/
