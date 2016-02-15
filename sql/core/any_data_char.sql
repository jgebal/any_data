create or replace type any_data_char under any_data(
   data_value varchar2(32767),
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_char( self in out nocopy any_data_char, p_data varchar2 ) return self as result,
   constructor function any_data_char( self in out nocopy any_data_char, type_info any_type, data_value varchar2 ) return self as result
);
/

create or replace type body any_data_char as

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return string_array( ''''||replace( data_value, '''', '''''')||'''' || p_separator );
      end;

   constructor function any_data_char( self in out nocopy any_data_char, p_data varchar2 ) return self as result is
      begin
         self.type_info := any_type( dbms_types.typecode_number, 'CHAR' );
         self.data_value := trim(p_data);
         return;
      end;

   constructor function any_data_char( self in out nocopy any_data_char, type_info any_type, data_value varchar2 ) return self as result is
      begin
         self.type_info := type_info;
         self.data_value := trim(data_value);
         return;
      end;
end;
/
