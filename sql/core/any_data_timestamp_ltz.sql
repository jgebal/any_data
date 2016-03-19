create or replace type any_data_timestamp_ltz authid current_user under any_data_family_date(
   data_value timestamp(9) with local time zone,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_timestamp_ltz( self in out nocopy any_data_timestamp_ltz, p_data timestamp_ltz_unconstrained ) return self as result
);
/

create or replace type body any_data_timestamp_ltz as

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return
         string_array(
            q'[to_timestamp_ltz( ']'
            || to_char( data_value, 'yyyy-mm-dd hh24:mi:ssxff9 tzh:tzm' )
            || q'[', 'yyyy-mm-dd hh24:mi:ssxff9 tzh:tzm' )]'
            || p_separator
         );
      end;

   constructor function any_data_timestamp_ltz( self in out nocopy any_data_timestamp_ltz, p_data timestamp_ltz_unconstrained ) return self as result is
      begin
         self.type_code := dbms_types.typecode_timestamp_ltz;
         self.type_name := 'TIMESTAMP WITH LOCAL TIME ZONE';
         self.self_type_name := 'any_data_timestamp_ltz';
         self.data_value := p_data;
         return;
      end;

end;
/
