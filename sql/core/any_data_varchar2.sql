create or replace type any_data_varchar2 under any_data(
   data_value varchar2(32767),
   overriding member function to_string return varchar2,
   constructor function any_data_varchar2( p_data varchar2 ) return self as result
);
/

create or replace type body any_data_varchar2 as

   overriding member function to_string return varchar2 is
      begin
         return ''''||replace( data_value, '''', '''''')||'''';
      end;

   constructor function any_data_varchar2( p_data varchar2 ) return self as result is
      begin
         self.type_info := any_type( dbms_types.typecode_number, 'VARCHAR2' );
         self.data_value := p_data;
         return;
      end;

end;
/
