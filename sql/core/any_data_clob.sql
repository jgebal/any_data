create or replace type any_data_clob under any_data(
   data_value clob,
   overriding member function to_string return varchar2,
   constructor function any_data_clob( p_data clob ) return self as result
);
/

create or replace type body any_data_clob as

   overriding member function to_string return varchar2 is
      begin
         return to_char( dbms_lob.substr( data_value, any_data_formatter.max_return_data_length ) );
      end;

   constructor function any_data_clob( p_data clob ) return self as result is
      begin
         self.type_info := any_type( dbms_types.typecode_number, 'BLOB' );
         self.data_value := p_data;
         return;
      end;

end;
/
