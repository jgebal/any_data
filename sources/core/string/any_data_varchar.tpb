create or replace type body any_data_varchar as

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return string_array( ''''||replace( data_value, '''', '''''')||'''' || p_separator );
      end;

   constructor function any_data_varchar( self in out nocopy any_data_varchar, p_data varchar ) return self as result is
      begin
         self.type_code := dbms_types.typecode_varchar;
         self.type_name := 'VARCHAR';
         self.self_type_name := $$PLSQL_UNIT;
         self.data_value := p_data;
         self.type_hash := dbms_crypto.hash( utl_raw.cast_to_raw(self.type_name), dbms_crypto.HASH_MD5 );
         self.value_hash := dbms_crypto.hash( utl_raw.cast_to_raw(self.data_value), dbms_crypto.HASH_MD5 );
         return;
      end;

end;
/
