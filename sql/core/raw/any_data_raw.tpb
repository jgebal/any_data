create or replace type body any_data_raw as

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return string_array( ''''||replace( utl_raw.cast_to_varchar2( data_value ), '''', '''''')||'''' || p_separator );
      end;

   constructor function any_data_raw( self in out nocopy any_data_raw, p_data raw ) return self as result is
      begin
         self.type_code := dbms_types.typecode_raw;
         self.type_name := 'RAW';
         self.self_type_name := 'any_data_raw';
         self.data_value := p_data;
         return;
      end;

end;
/
