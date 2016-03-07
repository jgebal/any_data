create or replace type any_data_clob authid current_user under any_data_family_string(
   data_value clob,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_clob( self in out nocopy any_data_clob, p_data clob ) return self as result
);
/

create or replace type body any_data_clob as

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return string_array( ''''||replace( to_char( dbms_lob.substr( data_value, any_data_const.max_return_data_length ) ) , '''', '''''')||'''' || p_separator );
      end;

   constructor function any_data_clob( self in out nocopy any_data_clob, p_data clob ) return self as result is
      begin
         self.type_code := dbms_types.typecode_clob;
         self.type_name := 'CLOB';
         self.self_type_name := 'any_data_clob';
         self.data_value := p_data;
         return;
      end;

end;
/
