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
         self.self_type_name := $$PLSQL_UNIT;
         self.data_value := p_data;
         return;
      end;

   overriding member function get_value_hash return raw is
      begin
         return
            case when self.data_value is null then any_data_const.null_hash_value
            else dbms_crypto.hash( utl_raw.cast_to_raw(to_char( data_value, 'yyyy-mm-dd hh24:mi:ssxff9 tzh:tzm' )), dbms_crypto.HASH_MD5 )
            end;
      end;

end;
/
