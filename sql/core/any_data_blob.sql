create or replace type any_data_blob under any_data(
   data_value blob,
   overriding member function to_string return varchar2,
   constructor function any_data_blob( self in out nocopy any_data_blob, p_data blob ) return self as result
);
/

create or replace type body any_data_blob as

   overriding member function to_string return varchar2 is
      begin
         return ''''||replace( utl_raw.cast_to_varchar2( dbms_lob.substr( data_value, any_data_formatter.max_return_data_length ) ), '''', '''''')||'''';
      end;

   constructor function any_data_blob( self in out nocopy any_data_blob, p_data blob ) return self as result is
      begin
         self.type_info := any_type( dbms_types.typecode_number, 'BLOB' );
         self.data_value := p_data;
         return;
      end;

end;
/
