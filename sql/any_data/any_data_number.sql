drop type any_data_number force;
/

create or replace type any_data_number under any_data(
   data_value number,
   overriding member function to_string return varchar2,
   overriding member procedure initialise( self in out nocopy any_data_number, p_data anydata ),
   constructor function any_data_number return self as result
);
/

create or replace type body any_data_number as

   overriding member function to_string return varchar2 is
      begin
         return to_char( data_value );
      end;

   overriding member procedure initialise( self in out nocopy any_data_number, p_data anydata ) is
      begin
         if p_data.getNumber( self.data_value ) = DBMS_TYPES.NO_DATA then
            raise NO_DATA_FOUND;
         end if;
      end;

   constructor function any_data_number return self as result is
      begin
         self.type_info := any_type( dbms_types.typecode_number, 'NUMBER' );
         return;
      end;

end;
/
