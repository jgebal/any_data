create or replace type body any_data_bdouble as

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return string_array( to_char( data_value ) || p_separator );
      end;

   constructor function any_data_bdouble( self in out nocopy any_data_bdouble, p_data binary_double ) return self as result is
      begin
         self.type_code := dbms_types.typecode_bdouble;
         self.type_name := 'BINARY_DOUBLE';
         self.self_type_name := 'any_data_bdouble';
         self.data_value := p_data;
         return;
      end;

end;
/
