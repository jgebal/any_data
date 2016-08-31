create or replace type body any_data_clob as

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return string_array( ''''||replace( to_char( dbms_lob.substr( data_value, any_data_const.max_return_data_length ) ) , '''', '''''')||'''' || p_separator );
      end;

   constructor function any_data_clob( self in out nocopy any_data_clob, p_data clob ) return self as result is
      begin
         self.type_code := dbms_types.typecode_clob;
         self.type_name := 'CLOB';
         self.self_type_name := $$PLSQL_UNIT;
         self.data_value := p_data;
         self.type_hash := dbms_crypto.hash( utl_raw.cast_to_raw(self.type_name), dbms_crypto.HASH_MD5 );
         if self.data_value is not null then
            self.value_hash := dbms_crypto.hash( self.data_value, dbms_crypto.HASH_MD5 );
         end if;
         return;
      end;

end;
/
