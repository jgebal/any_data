create or replace type any_data_timestamp authid current_user under any_data_family_date(
   data_value timestamp(9),
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_timestamp( self in out nocopy any_data_timestamp, p_data timestamp_unconstrained ) return self as result
);
/
