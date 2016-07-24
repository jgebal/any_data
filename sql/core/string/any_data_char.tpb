create or replace type body any_data_char as

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return string_array( ''''||replace( data_value, '''', '''''')||'''' || p_separator );
      end;

   constructor function any_data_char( self in out nocopy any_data_char, data_value varchar2 ) return self as result is
      begin
         self.type_code := dbms_types.typecode_char;
         self.type_name := 'CHAR';
         self.self_type_name := 'any_data_char';
         self.data_value := trim(data_value);
         return;
      end;

   constructor function any_data_char( self in out nocopy any_data_char, type_code number, type_name varchar2, self_type_name varchar2, data_value varchar2 ) return self as result is
      begin
         self.type_code := dbms_types.typecode_char;
         self.type_name := 'CHAR';
         self.self_type_name := 'any_data_char';
         self.data_value := trim(data_value);
         return;
      end;

end;
/
