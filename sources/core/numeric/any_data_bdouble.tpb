create or replace type body any_data_bdouble as

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return string_array( to_char( data_value ) || p_separator );
      end;

   constructor function any_data_bdouble( self in out nocopy any_data_bdouble, p_data binary_double ) return self as result is
      begin
         self.type_code := dbms_types.typecode_bdouble;
         self.type_name := 'BINARY_DOUBLE';
         self.self_type_name := $$PLSQL_UNIT;
         self.data_value := p_data;
         self.type_hash := dbms_crypto.hash( utl_raw.cast_to_raw(self.type_name), dbms_crypto.HASH_MD5 );
         self.value_hash := dbms_crypto.hash( utl_raw.cast_to_raw(to_char( data_value )), dbms_crypto.HASH_MD5 );
         return;
      end;

end;
/
