create or replace type any_data_timestamp_tz authid current_user under any_data_family_date(
   data_value timestamp(9) with time zone,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_timestamp_tz( self in out nocopy any_data_timestamp_tz, p_data timestamp_tz_unconstrained ) return self as result,
   overriding member function get_value_hash return raw
);
/
