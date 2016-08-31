create or replace type body any_data_number as

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return string_array( to_char( data_value ) || p_separator );
      end;

   constructor function any_data_number( self in out nocopy any_data_number, p_data number ) return self as result is
      begin
         self.type_code := dbms_types.typecode_number;
         self.type_name := 'NUMBER';
         self.self_type_name := $$PLSQL_UNIT;
         self.data_value := p_data;
         self.type_hash := dbms_crypto.hash( utl_raw.cast_to_raw(self.type_name), dbms_crypto.HASH_MD5 );
         self.value_hash := dbms_crypto.hash( utl_raw.cast_to_raw( data_value ), dbms_crypto.HASH_MD5 );
         return;
      end;

end;
/
