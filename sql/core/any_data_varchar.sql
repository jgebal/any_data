create or replace type any_data_varchar under any_data(
   data_value varchar(32767),
   overriding member function to_string return varchar2,
   constructor function any_data_varchar( self in out nocopy any_data_varchar, p_data varchar ) return self as result
);
/

create or replace type body any_data_varchar as

   overriding member function to_string return varchar2 is
      begin
         return ''''||replace( data_value, '''', '''''')||'''';
      end;

   constructor function any_data_varchar( self in out nocopy any_data_varchar, p_data varchar ) return self as result is
      begin
         self.type_info := any_type( dbms_types.typecode_number, 'VARCHAR' );
         self.data_value := p_data;
         return;
      end;

end;
/
