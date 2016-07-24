create or replace type body any_data_timestamp_tz as

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return
         string_array(
            q'[to_timestamp_tz( ']'
            || to_char( data_value, 'yyyy-mm-dd hh24:mi:ssxff9 tzh:tzm' )
            || q'[', 'yyyy-mm-dd hh24:mi:ssxff9 tzh:tzm' )]'
            || p_separator
         );
      end;

   constructor function any_data_timestamp_tz( self in out nocopy any_data_timestamp_tz, p_data timestamp_tz_unconstrained ) return self as result is
      begin
         self.type_code := dbms_types.typecode_timestamp_tz;
         self.type_name := 'TIMESTAMP WITH TIME ZONE';
         self.self_type_name := 'any_data_timestamp_tz';
         self.data_value := p_data;
         return;
      end;

end;
/
