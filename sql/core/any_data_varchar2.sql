create or replace type any_data_varchar2 under any_data(
   data_value varchar2(32767),
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_varchar2( self in out nocopy any_data_varchar2, p_data varchar2 ) return self as result
);
/

create or replace type body any_data_varchar2 as

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return string_array( ''''||replace( data_value, '''', '''''')||'''' || p_separator );
      end;

   constructor function any_data_varchar2( self in out nocopy any_data_varchar2, p_data varchar2 ) return self as result is
      begin
         self.type_info := any_type( dbms_types.typecode_number, 'VARCHAR2' );
         self.data_value := p_data;
         return;
      end;

end;
/
