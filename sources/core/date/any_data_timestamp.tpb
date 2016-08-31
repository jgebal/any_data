create or replace type body any_data_timestamp as

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return
         string_array(
            q'[to_timestamp( ']'
            || to_char( data_value, 'yyyy-mm-dd hh24:mi:ssxff9' )
            || q'[', 'yyyy-mm-dd hh24:mi:ssxff9' )]'
            || p_separator
         );
      end;

   constructor function any_data_timestamp( self in out nocopy any_data_timestamp, p_data timestamp_unconstrained ) return self as result is
      begin
         self.type_code := dbms_types.typecode_timestamp;
         self.type_name := 'TIMESTAMP';
         self.self_type_name := $$PLSQL_UNIT;
         self.data_value := p_data;
         self.type_hash := dbms_crypto.hash( utl_raw.cast_to_raw(self.type_name), dbms_crypto.HASH_MD5 );
         self.value_hash := dbms_crypto.hash( utl_raw.cast_to_raw(to_char( data_value, 'yyyy-mm-dd hh24:mi:ssxff9' )), dbms_crypto.HASH_MD5 );
         return;
      end;

end;
/
