create or replace type any_data_bfloat under any_data(
   data_value binary_float,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_bfloat( self in out nocopy any_data_bfloat, p_data binary_float ) return self as result
);
/

create or replace type body any_data_bfloat as

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return string_array( to_char( data_value ) || p_separator );
      end;

   constructor function any_data_bfloat( self in out nocopy any_data_bfloat, p_data binary_float ) return self as result is
      begin
         self.type_info := any_type( dbms_types.typecode_number, 'BINARY_FLOAT' );
         self.data_value := p_data;
         return;
      end;

end;
/
